module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.ts', '**/src/**/*.test.ts'], //  Updated to include .test.ts files in src
  moduleFileExtensions: ['ts', 'js', 'json', 'node'],
};
