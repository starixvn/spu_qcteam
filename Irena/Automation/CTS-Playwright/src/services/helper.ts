import * as fs from 'fs';
import * as path from 'path';

export interface CSVData {
    headers: string[];
    rows: string[][];
    rowCount: number;
}

export interface IHelperService {
    readCSV(filePath: string, separator?: string, encoding?: BufferEncoding): CSVData;
    csvRowToObject(headers: string[], row: string[]): Record<string, string>;
    validateCSV(csvData: CSVData, requiredHeaders?: string[]): { isValid: boolean; errors: string[] };
    writeJSON(filePath: string, data: any, indent?: number, encoding?: BufferEncoding): boolean;
    readJSON<T = any>(filePath: string, encoding?: BufferEncoding): T;
    validateJSONFile(filePath: string): { isValid: boolean; exists: boolean; error?: string };
    mergeJSON(filePath: string, newData: any, deepMerge?: boolean, indent?: number): boolean;
    base64Encode(input: string): string;
    base64Decode(base64: string): string;
}

export class HelperService implements IHelperService {
    readCSV(filePath: string, separator: string = "|", encoding: BufferEncoding = "utf-8"): CSVData {
        if (!filePath || typeof filePath !== 'string') {
            throw new Error('File path must be a non-empty string');
        }

        if (!fs.existsSync(filePath)) {
            throw new Error(`CSV file not found: ${filePath}`);
        }

        let csvContent: string;
        try {
            csvContent = fs.readFileSync(filePath, encoding);
        } catch (error) {
            throw new Error(`Failed to read CSV file '${filePath}': ${error}`);
        }

        if (!csvContent.trim()) {
            throw new Error(`CSV file is empty: ${filePath}`);
        }

        const lines = csvContent
            .trim()
            .split(/\r?\n/) // Handle both Windows and Unix line endings
            .map(line => line.trim())
            .filter(line => line.length > 0);

        if (lines.length < 1) {
            throw new Error(`CSV file must have at least a header row: ${filePath}`);
        }

        const headers = this.parseCsvLine(lines[0], separator);
        const rows: string[][] = [];

        for (let i = 1; i < lines.length; i++) {
            try {
                const values = this.parseCsvLine(lines[i], separator);
                
                // Normalize row length to match headers
                while (values.length < headers.length) values.push("");
                if (values.length > headers.length) values.splice(headers.length);
                
                rows.push(values);
            } catch (error) {
                throw new Error(`Error parsing CSV line ${i + 1} in '${filePath}': ${error}`);
            }
        }

        return { headers, rows, rowCount: rows.length };
    }

    private parseCsvLine(line: string, separator: string): string[] {
        // Simple CSV parsing - can be enhanced for quoted fields if needed
        return line.split(separator).map(field => field.trim());
    }

    csvRowToObject(headers: string[], row: string[]): Record<string, string> {
        const result: Record<string, string> = {};
        headers.forEach((header, index) => {
            result[header] = row[index] || "";
        });
        return result;
    }

    validateCSV(csvData: CSVData, requiredHeaders?: string[]): { isValid: boolean; errors: string[] } {
        const errors: string[] = [];

        if (!csvData.headers || csvData.headers.length === 0) {
            errors.push("CSV headers are missing or empty");
        }

        const headerSet = new Set(csvData.headers);
        if (headerSet.size !== csvData.headers.length) {
            errors.push("CSV contains duplicate headers");
        }

        if (requiredHeaders && requiredHeaders.length > 0) {
            const missing = requiredHeaders.filter(h => !csvData.headers.includes(h));
            if (missing.length > 0) errors.push(`Missing required headers: ${missing.join(", ")}`);
        }

        const expectedColumnCount = csvData.headers.length;
        csvData.rows.forEach((row, index) => {
            if (row.length !== expectedColumnCount) {
            errors.push(`Row ${index + 1} has ${row.length} columns, expected ${expectedColumnCount}`);
            }
        });

        return { isValid: errors.length === 0, errors };
    }

    writeJSON(filePath: string, data: any, indent: number = 2, encoding: BufferEncoding = "utf-8"): boolean {
        if (!filePath || typeof filePath !== 'string') {
            throw new Error('File path must be a non-empty string');
        }

        if (data === undefined) {
            throw new Error('Data to write cannot be undefined');
        }

        try {
            const dir = path.dirname(filePath);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
            
            const jsonString = JSON.stringify(data, null, indent);
            fs.writeFileSync(filePath, jsonString, encoding);
            return true;
        } catch (error) {
            if (error instanceof TypeError) {
                throw new Error(`Cannot serialize data to JSON for file '${filePath}': ${error.message}`);
            }
            throw new Error(`Failed to write JSON file '${filePath}': ${error}`);
        }
    }

    readJSON<T = any>(filePath: string, encoding: BufferEncoding = "utf-8"): T {
        if (!filePath || typeof filePath !== 'string') {
            throw new Error('File path must be a non-empty string');
        }

        if (!fs.existsSync(filePath)) {
            throw new Error(`JSON file not found: ${filePath}`);
        }

        let jsonContent: string;
        try {
            jsonContent = fs.readFileSync(filePath, encoding);
        } catch (error) {
            throw new Error(`Failed to read JSON file '${filePath}': ${error}`);
        }

        if (!jsonContent.trim()) {
            throw new Error(`JSON file is empty: ${filePath}`);
        }

        try {
            return JSON.parse(jsonContent) as T;
        } catch (error) {
            throw new Error(`Invalid JSON format in file '${filePath}': ${error}`);
        }
    }

    validateJSONFile(filePath: string): { isValid: boolean; exists: boolean; error?: string } {
        if (!fs.existsSync(filePath)) {
            return { isValid: false, exists: false, error: "File does not exist" };
        }

        try {
            const content = fs.readFileSync(filePath, "utf-8");
            JSON.parse(content);
            return { isValid: true, exists: true };
        } catch (error) {
            return { isValid: false, exists: true, error: `Invalid JSON: ${error}` };
        }
    }

    mergeJSON(filePath: string, newData: any, deepMerge: boolean = true, indent: number = 2): boolean {
        if (!filePath || typeof filePath !== 'string') {
            throw new Error('File path must be a non-empty string');
        }

        if (newData === undefined || newData === null) {
            throw new Error('New data cannot be undefined or null');
        }

        try {
            let existingData = {};
            if (fs.existsSync(filePath)) {
                existingData = this.readJSON(filePath);
            }

            let mergedData: any;
            if (deepMerge && 
                existingData && typeof existingData === "object" && !Array.isArray(existingData) &&
                newData && typeof newData === "object" && !Array.isArray(newData)) {
                mergedData = this.deepMergeObjects(existingData, newData);
            } else {
                // Shallow merge or fallback for non-objects
                if (typeof existingData === "object" && typeof newData === "object") {
                    mergedData = { ...existingData, ...newData };
                } else {
                    mergedData = newData; // Replace entirely if not both objects
                }
            }

            return this.writeJSON(filePath, mergedData, indent);
        } catch (error) {
            throw new Error(`Failed to merge JSON file '${filePath}': ${error}`);
        }
    }

    private deepMergeObjects(target: any, source: any): any {
        const result = { ...target };
        for (const key in source) {
            if (source.hasOwnProperty(key)) {
            if (
                typeof source[key] === "object" &&
                source[key] !== null &&
                !Array.isArray(source[key]) &&
                typeof result[key] === "object" &&
                result[key] !== null &&
                !Array.isArray(result[key])
            ) {
                result[key] = this.deepMergeObjects(result[key], source[key]);
            } else {
                result[key] = source[key];
            }
            }
        }
        return result;
    }

    base64Encode(input: string): string {
        if (typeof input !== 'string') {
            throw new Error('Input must be a string');
        }

        try {
            return Buffer.from(input, "utf-8").toString("base64");
        } catch (error) {
            throw new Error(`Failed to encode string to base64: ${error}`);
        }
    }

    base64Decode(base64: string): string {
        if (typeof base64 !== 'string') {
            throw new Error('Base64 input must be a string');
        }

        const trimmedBase64 = base64.trim();
        if (trimmedBase64.length === 0) {
            return '';
        }
        
        try {
            return Buffer.from(trimmedBase64, "base64").toString("utf-8");
        } catch (error) {
            throw new Error(`Failed to decode base64 string: ${error}`);
        }
    }
}