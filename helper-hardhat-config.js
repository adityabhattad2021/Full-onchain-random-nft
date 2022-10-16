const { ethers } = require("hardhat");

const deveplomentChains = ["hardhat", "localhost"];

const networkConfig = {
	5: {
		name: "georli",
		vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
		gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
		subscriptionId: 4611,
		callBackGasLimit: "1500000",
	},
	1337: {
		name: "hardhat",
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        callBackGasLimit:"1500000"
	},
	1337: {
		name: "localhost",
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        callBackGasLimit:"1500000"
	},
};

module.exports = {
	deveplomentChains,
	networkConfig,
};
