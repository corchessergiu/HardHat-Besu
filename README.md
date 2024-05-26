### Prerequisites
* Besu -> https://besu.hyperledger.org/public-networks/get-started/install/binary-distribution
* HardHat framework -> https://hardhat.org/tutorial

### Execute all the commands below in the root directory!
### Steps

1. Installing dependencies
 `npm install` 

2. Compiling smart contract
`npx hardhat compile`

3. Running a Hyperledger Besu node
`besu --network=dev --miner-enabled --miner-coinbase=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 --rpc-http-cors-origins='all' --host-allowlist='*' --rpc-ws-enabled --rpc-http-enabled --data-path=/home/sergiu/Desktop/BesuData --logging=DEBUG
`
![Screenshot from 2024-05-26 17-17-40](https://github.com/corchessergiu/HardHat-Besu/assets/61419684/11d8698e-ff5a-421f-a88c-90121826a0e6)

4. Running deploy script
`npx hardhat run scripts/deploy.js --network besu`


