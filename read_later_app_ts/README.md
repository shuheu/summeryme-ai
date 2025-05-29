# Read Later CLI Application (TypeScript)

A simple command-line application built with TypeScript to save and manage a list of URLs to read later.

## Prerequisites

- Node.js (v16 or later recommended)
- npm (comes with Node.js) or yarn

## Setup Instructions

1.  **Clone the repository** (if you haven't already):
    ```bash
    git clone <repository_url>
    cd <repository_name> 
    ```
    (If already cloned, navigate to the project root)

2.  **Change into the application directory**:
    ```bash
    cd read_later_app_ts
    ```

3.  **Install dependencies**:
    ```bash
    npm install
    ```

## Compilation

To compile the TypeScript code into JavaScript, run the following command from the `read_later_app_ts` directory:

```bash
npm run build
```
(Note: This requires a "build" script to be defined in `package.json`, typically `tsc`.)

## Usage Instructions

Once compiled, run the application from the `read_later_app_ts` directory using `node` with the compiled output in the `dist` folder:

```bash
node dist/main.js <command> [arguments]
```

### Available Commands:

-   **`add <URL>`**: Saves a new URL to your reading list.
    -   Example: `node dist/main.js add https://www.typescriptlang.org/`

-   **`list`**: Displays all currently saved URLs with their indices.
    -   Example: `node dist/main.js list`

-   **`read <index>`**: Marks a URL at the given index as "read". This action removes the URL from the list.
    -   Example: `node dist/main.js read 0` (Marks the first URL as read and removes it)

-   **`remove <index>`**: Removes a URL at the given index from the list.
    -   Example: `node dist/main.js remove 1` (Removes the second URL from the list)

If no command is provided, the application will list existing links and show usage instructions.

## Running Tests

To run the unit tests, use the following command from the `read_later_app_ts` directory:

```bash
npm test
```
(Note: This requires a "test" script to be defined in `package.json`, typically `jest`.)

