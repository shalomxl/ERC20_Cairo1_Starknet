# A Starknet smart contract project by Cairo1

## Project directory structure

```
.
├── README.md
├── Scarb.toml          // A config file by Scarb
├── cairo_project.toml  // A configuration file that specifies the location of the contract code. 
├── sierra              // The output location of contract compilation.
│   └── erc20.json
└── src                 // Dir of contract code
    ├── erc20.cairo
    ├── error.cairo
    ├── lib.cairo
    └── tests.cairo
```

## The references between .cairo files.

First, you need to treat the entire project as a package and configure the package name in Scarb.toml. Like this:

```
[package]
name = "protostar_contract_01"
```

Then, it is necessary to declare all the packages in the project in `lib.cairo`.

```
mod error;
```

An file named `error.cairo` is required. And `erc20.cairo` can import the code of `error.cairo`.

```
...
use protostar_contract_01::error;
...
assert(currentAllowance >= _subedAmount, error::INSUFFICIENT_ALLOWANCE);
...
```

## Compile smart contract

There are two ways to compile contracts.

1. starknet-compile
2. scarb

### starknet-compile

```
starknet-compile . sierra/erc20.json
```

### scarb

Need to add `[[target.starknet-contract]]` into `Scarb.toml`.

```toml
[[target.starknet-contract]]
# Enable Sierra codegen.
sierra = true
# Enable CASM codegen.
casm = false
# Emit Python-powered hints in order to run compiled CASM class with legacy Cairo VM.
casm-add-pythonic-hints = false
```

Run:

```
scarb build
```

## Declare and deploy smart contract

Declare:

```sh
starknet declare --contract sierra/erc20.json --account v0.11.0.2
```

Deploy:

```sh
starknet deploy --class_hash 0x137520fe7ed94c5f4172277c9136856b3ac7662d26205d2afe30b036d98a9d7 --inputs 0x55534454 0x596f75205342  --account v0.11.0.2
```

## Test smart contract

Use `cairo-test`

```
cairo-test --starknet --path .
```