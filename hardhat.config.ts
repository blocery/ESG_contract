
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const MAIN_PRIVATE_KEY = process.env.MAIN_PRIVATE_KEY;
const BASE_PRIVATE_KEY = process.env.BASE_PRIVATE_KEY;
const ETHEREUM_SEPOLIA_RPC_URL = process.env.ETHEREUM_SEPOLIA_RPC_URL;
const POLYGON_MUMBAI_RPC_URL = process.env.POLYGON_MUMBAI_RPC_URL;
const OPTIMISM_GOERLI_RPC_URL = process.env.OPTIMISM_GOERLI_RPC_URL;
const ARBITRUM_TESTNET_RPC_URL = process.env.ARBITRUM_TESTNET_RPC_URL;
const AVALANCHE_FUJI_RPC_URL = process.env.AVALANCHE_FUJI_RPC_URL;
const AVALANCHE_RPC_URL = process.env.AVALANCHE_RPC_URL;
const BNBCHAIN_TESTNET_RPC_URL = process.env.BNBCHAIN_TESTNET_RPC_URL;
const BASECHAIN_TESTNET_RPC_URL = process.env.BASECHAIN_TESTNET_RPC_URL;

const config: HardhatUserConfig = {
  solidity: {
       version: "0.8.20",
       settings: {          
            optimizer: {
              enabled: true,
              runs: 200
          },
          viaIR: true,
       },
  },
  networks: {
    hardhat: {
      chainId: 31337
    },
    ethereumSepolia: {
      url: ETHEREUM_SEPOLIA_RPC_URL !== undefined ? ETHEREUM_SEPOLIA_RPC_URL : '',
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 11155111
    },
    polygonMumbai: {
      url: POLYGON_MUMBAI_RPC_URL !== undefined ? POLYGON_MUMBAI_RPC_URL : '',
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 80001
    },
    optimismGoerli: {
      url: OPTIMISM_GOERLI_RPC_URL !== undefined ? OPTIMISM_GOERLI_RPC_URL : '',
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 420,
    },
    arbitrumTestnet: {
      url: ARBITRUM_TESTNET_RPC_URL !== undefined ? ARBITRUM_TESTNET_RPC_URL : '',
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 421613
    },
    avalancheFuji: {
      url: AVALANCHE_FUJI_RPC_URL !== undefined ? AVALANCHE_FUJI_RPC_URL : '',
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 43113
    },
    avalanche: {
      url: AVALANCHE_RPC_URL !== undefined ? AVALANCHE_RPC_URL : '',
      accounts: MAIN_PRIVATE_KEY !== undefined ? [MAIN_PRIVATE_KEY] : [],
      chainId: 43114
    },
    bnbTestnet: {
      url: BNBCHAIN_TESTNET_RPC_URL !== undefined ? BNBCHAIN_TESTNET_RPC_URL: '',
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 97
    },
    baseTestnet: {
      url: BASECHAIN_TESTNET_RPC_URL !== undefined ? BASECHAIN_TESTNET_RPC_URL: '',
      accounts: BASE_PRIVATE_KEY !== undefined ? [BASE_PRIVATE_KEY] : [],
      chainId: 84532
    }
  },
  typechain: {
    externalArtifacts: ['./abi/*.json']
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts'
  },
};

export default config;
