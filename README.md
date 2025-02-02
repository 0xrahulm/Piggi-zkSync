Smart Contracts for Piggi - The Web 3.0 Marketing Stack as described in whitepaper - https://whitepaper.piggi.ai/

Steps to Run
1. yarn install
2. update private key in .env
3. yarn hardhat compile
4. to get estimated deployment fee run : yarn hardhat deploy-zksync --script deployFeeEstimate.ts
5. yarn hardhat deploy-zksync
6. yarn ts-node scripts/updateManagersInExperience.ts
