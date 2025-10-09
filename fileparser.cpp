// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

#include "fileparser.h"
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <iomanip>
#include <optional>
#include <ranges>
#include <string_view>

enum class Stage
{
    Fetch = 0,
    Decode,
    Execute,
    Memory,
    WriteBack
};

// Array to hold all possible stages
const Stage STAGES[] = { Stage::Fetch, Stage::Decode, Stage::Execute, Stage::Memory, Stage::WriteBack };

void trim(std::string& str)
{
    str.erase(std::remove_if(str.begin(), str.end(), ::isspace), str.end());
}

// Function to convert string to Stage enum
Stage from_string(std::string& a)
{
    trim(a);
    if (a == "fetch1")
        return Stage::Fetch;
    if (a == "decode")
        return Stage::Decode;
    if (a == "execute")
        return Stage::Execute;
    if (a == "memory")
        return Stage::Memory;
    if (a == "writeback")
        return Stage::WriteBack;
    throw std::invalid_argument("Invalid stage: " + a);
}

// Structure to represent a log entry
struct LogEntry
{
    std::string instruction;
    uint64_t tick;
    size_t address;
    Stage stage;
    bool stalled;
    std::optional<int32_t> function_unit;
};

// Class to handle log entries and provide various operations on them
class Log
{
public:
    std::vector<LogEntry> entries;
    uint64_t first_tick;
    int64_t first_writeback = -1;
    // Constructor to read log entries from a file
    Log(const std::string& path)
    {
        std::ifstream file(path);
        std::ofstream reg("./.reg_log"); //todo: riscrivi il path giusto
        if (!file.is_open())
        {
            throw std::runtime_error("Could not open file");
        }
        std::string line;
        while (std::getline(file, line))
        {
            line.erase(std::remove(line.begin(), line.end(), '\r'), line.end());
            if (line.find("REGISTERS") != std::string::npos) { //takes registers values for every CC, putting them in reg file
                for (int i = 0; i < 64; i++) { //32 int registers + 32 float
                    std::getline(file, line);
                    reg << line << '\n';
                }
            }
            if (line.find("Log4GUI") != std::string::npos) // && line.find("fetch1") == std::string::npos)
            {
                std::istringstream iss(line);
                std::string token;
                std::vector<std::string> data;
                while (std::getline(iss, token, ':'))
                {
                    data.push_back(token);
                }
                // Skip first three elements
                data.erase(data.begin(), data.begin() + 3);

                Stage stage = from_string(data[0]);
                uint64_t tick = std::stoull(data[1]) / 1000000;
                bool stalled = std::stoi(data[2]) != 0;
                size_t address = std::stoul(data[3], nullptr, 16);
                std::string instruction = data[4];
                std::optional<int32_t> function_unit;
                if (data.size() == 6)
                {
                    function_unit = std::stoi(data[5]);
                }
                entries.push_back({ instruction, tick, address, stage, stalled, function_unit });
                if (stage == Stage::WriteBack && first_writeback == -1)
                {
                    first_writeback = tick;
                }
            }
        }
        // Adjust ticks to start from 0
        // if (!entries.empty())
        // {
        //     first_tick = entries[0].tick;
        //     for (auto& entry : entries)
        //     {
        //         entry.tick -= first_tick;
        //     }
        // }
    }

    // Group log entries by tick
    std::map<uint64_t, std::vector<std::optional<LogEntry>>> by_tick()
    {
        std::map<uint64_t, std::vector<std::optional<LogEntry>>> map;
        for (const auto& entry : entries)
        {
            map[entry.tick].push_back(std::optional<LogEntry>{entry});
            // map[entry.tick].resize(16);
	    // if (entry.stage == Stage::Execute && entry.function_unit.has_value()) {
        //     if (map[entry.tick][5 + entry.function_unit.value()].has_value()) {
        //         map[entry.tick].push_back(std::optional<LogEntry>(entry));
        //     }
		// map[entry.tick][5 + entry.function_unit.value()] = entry;
	    // } else {
        //     	map[entry.tick][static_cast<size_t>(entry.stage)] = entry;
	    // }
        }
        // Handle fetch stage based on decode stage
        // auto it = map.begin();
        // while (it != map.end() && std::next(it) != map.end())
        // {
        //     auto next_it = std::next(it);
        //     if (next_it->second[1].has_value())
        //     {
        //         it->second[0]->instruction = next_it->second[1]->instruction;
        //     }
        //     ++it;
        // }
        return map;
    }

    // Map instructions to their addresses
    std::map<size_t, std::string> instrs_by_address()
    {
        std::map<size_t, std::string> map;
        for (const auto& entry : entries)
        {
            if (entry.instruction.find("<assembly>") == std::string::npos)
            {
                map[entry.address] = entry.instruction;
            }
        }
        return map;
    }

    // Group log entries by address
    std::map<uint64_t, std::vector<std::optional<LogEntry>>> by_address()
    {
        auto by_tick_map = by_tick();
        std::map<uint64_t, std::vector<std::optional<LogEntry>>> map;
        std::set<size_t> unique_addresses;
        for (const auto& entry : entries)
        {
            unique_addresses.insert(entry.address);
        }
        for (const auto& addr : unique_addresses)
        {
            std::vector<std::optional<LogEntry>> entries(5);
            for (const auto& [tick, stages] : by_tick_map)
            {
                auto it = std::find_if(stages.begin(), stages.end(), [&](const auto& e)
                                       { return e.has_value() && e->address == addr; });
                if (it != stages.end() && it->has_value())
                {
                    entries[static_cast<size_t>(it->value().stage)] = *it;
                }
            }
            map[addr] = entries;
        }
        return map;
    }

    // Print a diagram of the pipeline execution, now it prints the diagram on a file instead of the console
    void print_diagram()
    {
        std::ofstream fileout("./.badlog"); //todo: riscrivi il path giusto
        if (entries.empty())
            return;
        uint64_t min_tick = entries.front().tick;
        uint64_t max_tick = entries.back().tick;
        auto instrs_by_tick = by_tick();
        auto instrs_by_addr = instrs_by_address();

        for (const auto& [addr, instr] : instrs_by_addr)
        {
            fileout << std::setw(32) << std::left << fmt_hex(addr) + ": " + instr;
            for (uint64_t tick = min_tick; tick <= max_tick; ++tick)
            {
                auto it = instrs_by_tick.find(tick);
                if (it != instrs_by_tick.end())
                {
                    auto entry_it = std::find_if(it->second.begin(), it->second.end(), [&](const auto& e)
                                                 { return e.has_value() && e->address == addr; });
                    if (entry_it != it->second.end() && entry_it->has_value())
                    {
                        const auto& entry = entry_it->value();
                        char stage_abbr = get_stage_abbr(entry.stage);
                        if (entry.stalled)
                        {
                            fileout << 's';
                        }
                        else
                        {
                            if (entry.stage == Stage::Execute && entry.function_unit.has_value())
                            {
                                fileout << get_function_unit_str(entry.function_unit.value());
                            }
                            else
                            {
                                fileout << stage_abbr;
                            }
                        }
                    }
                    else
                    {
                        fileout << ' ';
                    }
                }
            }
            fileout << '\n';
        }
        fileout.close();
    }

private:
    // Helper function to convert address to hexadecimal string
    static std::string fmt_hex(size_t addr)
    {
        std::stringstream ss;
        ss << std::hex << addr;
        return ss.str();
    }

    // Helper function to get abbreviation for a stage
    static char get_stage_abbr(Stage stage)
    {
        switch (stage)
        {
        case Stage::Fetch:
            return 'F';
        case Stage::Decode:
            return 'D';
        case Stage::Execute:
            return 'E';
        case Stage::Memory:
            return 'M';
        case Stage::WriteBack:
            return 'W';
        default:
            return ' ';
        }
    }

    // Helper function to get function unit string based on its ID
    static char get_function_unit_str(int32_t fu)
    {
        switch (fu)
        {
        case 0:
            return 'E';
        case 1:
            return 'X';
        case 2:
            return 'd';
        case 3:
            return 'A';
        case 4:
            return 'X';
        case 5:
            return 'd';
        case 6:
            return 'B';
        default:
            return 'E';
        }
    }
};


void rewrite(uint64_t first_writeback_tick) {
    char capo = '\n';
    std::vector<std::string> pipe;
    std::ifstream filein("./.badlog"); //todo: riscrivi il path giusto
    std::ofstream fileout("./g5v_pipeline.txt"); //todo: riscrivi il path giusto
    std::ifstream regin("./.reg_log"); //todo: riscrivi il path giusto
    if (!filein.is_open() || !fileout.is_open() || !regin.is_open())
    {
        throw std::runtime_error("Rewrite: Could not open file");
    }
    std::size_t pos = 0;
    std::string line1, line2;
    std::getline(filein, line1);
    //line1[line1.find('D') - 1] = 'F';
    std::string first_instr_line = line1;
    //Loop on every row of the diagram
    while (std::getline(filein, line2)) {
        pos = 0;
        do {
            pos++;
//**********Section for adding stalls in the entire execution (for every FDEMW)
            pos = line2.find('W', pos);
            if (pos != std::string::npos) {

                size_t pos_fetch = line2.find_last_of('F', pos + 1);
                while (pos_fetch != std::string::npos && pos_fetch < line2.size() && line2[pos_fetch] != 'W') {
                    if (line2[pos_fetch] == ' ')
                        line2[pos_fetch] = 's';
                    pos_fetch++;
                    pos++;
                }
            }
        } while (pos != std::string::npos);
//******End section

        fileout.write(line1.c_str(), line1.size());
        pipe.push_back(line1);
        fileout.write(&capo, 1);
        line1.swap(line2);
    }
    fileout.write(line1.c_str(), line1.size()); //Print the last line
    fileout.write(&capo, 1);
    fileout.flush();
    pipe.push_back(line1);
    int CC = 1, count = 0, stall = 0;
    bool stallo = false;
//**Section to append registers ath the end of the file
    fileout << "REGISTERS\n";
    int64_t wb_offset = -1;
    int writeback_tick = first_instr_line.find('W') - first_instr_line.find('F') + 1;
    while (std::getline(regin, line1)) {
        std::istringstream iss(line1);
        std::string token;
        std::vector<std::string> data;
        while (std::getline(iss, token, ':'))
        {
            data.push_back(token);
        }
        line2 = line1.substr(line1.find(':'));
        if (wb_offset == -1)
        {
            wb_offset = std::stoull(data[0]) / 1000000 - writeback_tick;
        }
        fileout << std::stoull(data[0]) / 1000000 - wb_offset << ":" << data[2] << '\n';
        count++;
        if (count == 63) {
            count = 0;
            CC++;
        }
    }
//**End section
    
    fileout << "STATISTICHE\n";
//**Section to append statistics at the end of file
    int istruzioni = 0;
    float CPI = 0;
    int cmcmc = pipe.back().size();
    for (int i = 31; i <= pipe.back().size(); i++) { //i will also serve as CC counter (i-30)
        stallo = false;
        for (int j = 0; j < pipe.size(); j++) {
            if (i < pipe[j].size()) {
                if (pipe[j][i] == 's' && stallo == false) {
                    stallo = true;
                    stall++;
                }
                if (pipe[j][i] == 'W')
                    istruzioni++;
            }
        }
        if (istruzioni == 0)
            CPI = i - 30;
        else
            CPI = (float)((i - 30) / (float)istruzioni);
        fileout << i - 30 << ':' << " Clock_Cycle:" << i - 30 << '\n';
        fileout << i - 30 << ':' << " Instructions_Completed:" << istruzioni << '\n';
        fileout << i - 30 << ':' << " CPI:" << CPI << '\n';
        fileout << i - 30 << ':' << " Stalls:" << stall << '\n';
    }
//**End section
    
    fileout.close();
    filein.close();
    regin.close();
}

FileParser::FileParser(QObject *parent) : QObject{parent} {}

bool FileParser::parseFile(const QUrl &filePathUrl)
{
    try {
        Log log(filePathUrl.toLocalFile().toStdString()); //todo: riscrivi il path giusto
        log.print_diagram();
        rewrite(log.first_writeback);
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << '\n';
        return false;
    }

    int rowCounter = 0;
    int registerSwitch = 0;
    bool firstLine = true;
    int numOfPrecedingChars = -1;
    
    QUrl fileurl("file:g5v_pipeline.txt");
    QFile file(fileurl.toLocalFile());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;
    QTextStream inFile(&file);
    registers[0] = {"x0=0x00000000", "x1=0x00000000", "x2=0x00000000", "x3=0x00000000", "x4=0x00000000", "x5=0x00000000", "x6=0x00000000", "x7=0x00000000", "x8=0x00000000",
                   "x9=0x00000000", "x10=0x00000000", "x11=0x00000000", "x12=0x00000000", "x13=0x00000000", "x14=0x00000000", "x15=0x00000000", "x16=0x00000000",
                   "x17=0x00000000", "x18=0x00000000", "x19=0x00000000", "x20=0x00000000", "x21=0x00000000", "x22=0x00000000", "x23=0x00000000", "x24=0x00000000",
                   "x25=0x00000000", "x26=0x00000000", "x27=0x00000000", "x28=0x00000000", "x29=0x00000000", "x30=0x00000000", "x31=0x00000000",
                    "f0=0x00000000", "f1=0x00000000", "f2=0x00000000", "f3=0x00000000", "f4=0x00000000", "f5=0x00000000", "f6=0x00000000", "f7=0x00000000", "f8=0x00000000",
                    "f9=0x00000000", "f10=0x00000000", "f11=0x00000000", "f12=0x00000000", "f13=0x00000000", "f14=0x00000000", "f15=0x00000000", "f16=0x00000000",
                    "f17=0x00000000", "f18=0x00000000", "f19=0x00000000", "f20=0x00000000", "f21=0x00000000", "f22=0x00000000", "f23=0x00000000", "f24=0x00000000",
                    "f25=0x00000000", "f26=0x00000000", "f27=0x00000000", "f28=0x00000000", "f29=0x00000000", "f30=0x00000000", "f31=0x00000000"};
    stats[0] = {"Clock Cycle: 1", "Instructions Completed: 0", "CPI: 1", "Stalls: 0"};
    while (!inFile.atEnd()) {
        QString line = inFile.readLine();
        if (firstLine) {
            firstLine = false;
            numOfPrecedingChars = line.indexOf("F", 25);
        }
        if (line.contains("REGISTERS")) {
            registerSwitch = 1;
            continue;
        }
        if (line.contains("STATISTICHE")) {
            registerSwitch = 2;
            continue;
        }

        if (registerSwitch < 1){
            static QRegularExpression reg_regex(" {3,}");
            QString instr = line.split(reg_regex)[0];
            m_listData.append(instr);

            QStringList row;

            for(int i=numOfPrecedingChars; i<line.size(); i++) {
                if (line[i] == "F") {
                    fCC[i-numOfPrecedingChars+1] = rowCounter;
                }
                else if (line[i] == "s") {
                    numOfStalls++;
                }
                row.append(line[i]);
            }
            if(row.size() > longestRowVal)
                longestRowVal = row.size();
            m_tableData.append(row.toVector());
            rowCounter++;
        }
        else {
            QStringList splitRes = line.split(":");
            if (splitRes.size() == 1)
                break;
            int regCC = splitRes[0].toInt();
            // log regCC
            if (registerSwitch == 1) {
                registers[regCC].append(splitRes[1]);
            }
            else {
                stats[regCC].append(splitRes[1].replace(" ", "").replace("_", " ") + ": " + splitRes[2]);
            }

        }
    }

    file.close();
    emit readEnded();
    return true;
}

QUrl FileParser::stringConversion(const QString &path)
{
    return QUrl("file:" + path);
}

QString FileParser::colorToString(const QColor color)
{
    return color.name().remove(QChar('#'));
}

QStringList FileParser::getListData() const
{
    return m_listData;
}

QVector<QVector<QString> > FileParser::getTableData() const
{
    return m_tableData;
}

QMap<int, QStringList> FileParser::getRegisters() const
{
    return registers;
}

QMap<int, QStringList> FileParser::getStats() const
{
    return stats;
}

QStringList FileParser::getStringBycc(int CC)
{
    return registers.value(CC);
}

int FileParser::getMaxRowLen() const
{
    return longestRowVal;
}

void FileParser::clearData()
{
    m_listData.clear();
    m_tableData.clear();
    longestRowVal = -1;
    fCC.clear();
    registers.clear();
    stats.clear();
    numOfStalls = 0;
}

int FileParser::getNumOfInstr()
{
    return m_listData.size();
}

int FileParser::getHighlightedRowByCC(int cc)
{
    return fCC.contains(cc) ? fCC.value(cc) : -1;
}

int FileParser::getNumOfStalls()
{
    return numOfStalls;
}
