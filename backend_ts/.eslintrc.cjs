module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
    'plugin:import/typescript', // Added for import plugin
  ],
  plugins: ['@typescript-eslint', 'prettier', 'import'], // Added import plugin
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  env: {
    es6: true,
    node: true,
  },
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'build/',
    'coverage/',
    'src/prisma/generated/',
    'src/prisma/migrations/',
    '*.config.js',
    '*.config.cjs',
    '.env*',
    'docker-compose.yml',
    'Dockerfile',
  ],
  rules: {
    'prettier/prettier': 'error',
    '@typescript-eslint/no-unused-vars': 'warn',
    '@typescript-eslint/no-explicit-any': 'warn',
    'import/order': [
      // Added import sorting rules
      'error',
      {
        groups: [
          'builtin',
          'external',
          'internal',
          'parent',
          'sibling',
          'index',
          'object',
          'type',
        ],
        pathGroups: [
          {
            pattern: '@/**',
            group: 'internal',
            position: 'before',
          },
        ],
        alphabetize: {
          order: 'asc',
          caseInsensitive: true,
        },
        'newlines-between': 'always',
      },
    ],
    'import/no-duplicates': 'error', // Added rule to prevent duplicate imports
  },
  settings: {
    'import/resolver': {
      // Added resolver settings for typescript
      typescript: {},
    },
  },
};
