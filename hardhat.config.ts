import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-contract-sizer";
import dotenv from "dotenv";
import "hardhat-contract-sizer";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      // Fork mumbai testnet
      forking: {
        url: process.env.RPC_URL || "",
      },
    },
    goerli: {
      url: process.env.RPC_URL,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    sepolia: {
      url: process.env.RPC_URL,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    gnosis: {
      url: "https://rpc.gnosischain.com",
      accounts: [process.env.PRIVATE_KEY || ""],
    },    
    scrollAlpha: {
      url: "https://alpha-rpc.scroll.io/l2" || "",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    linea: {
      url: `https://rpc.goerli.linea.build/`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },     
  },
  etherscan: {
    apiKey: {
      scrollAlpha: 'abc',
      gnosis: 'your key',     
    },
    customChains: [
      {
        network: 'scrollAlpha',
        chainId: 534353,
        urls: {
          apiURL: 'https://blockscout.scroll.io/api',
          browserURL: 'https://blockscout.scroll.io/',
        },
      },
      {
        network: "gnosis",
        chainId: 100,
        urls: {
          // // Select to what explorer verify the contracts
          // Gnosisscan
          apiURL: "https://api.gnosisscan.io/api",
          browserURL: "https://gnosisscan.io/",
          // Blockscout
          //apiURL: "https://blockscout.com/xdai/mainnet/api",
          //browserURL: "https://blockscout.com/xdai/mainnet",
        },
      },      
    ],
  },
};


export default config;
