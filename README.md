# Customized ERC721 Project


This project demostrate vanilla ERC721 based on eip-721.

The project comes includes vanilla ERC721 Smart Contract alongwith, other eip based contract as mentioned below 
1. eip-165 (For validating interfaces) 
2. eip-712 (Standard for message signing) 
3. eip-721 (Standard for Non Fungible Token)
4. ERC721A (Optimized for minting)

The project also includes unit test cases in javascript, which demonstrate basic ERC721 features and gas optimization difference with standard ERC721 and optimized ERC721 for bulk minting for NFTs

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```