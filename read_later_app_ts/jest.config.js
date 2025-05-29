// read_later_app_ts/jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.ts', '**/*.test.ts'], // Added '**/*.test.ts' to find tests outside /tests
  moduleNameMapper: {
    '^@domain/(.*)$': '<rootDir>/src/domain/$1',
    '^@application/(.*)$': '<rootDir>/src/application/$1',
    '^@infrastructure/(.*)$': '<rootDir>/src/infrastructure/$1',
    '^@src/(.*)$': '<rootDir>/src/$1', // Matches aliases like @src/file
  },
  // Optional: Enable for coverage reports
  // collectCoverage: true, 
  // coverageDirectory: "coverage", 
  // coverageReporters: ["json", "lcov", "text", "clover"], 
};
