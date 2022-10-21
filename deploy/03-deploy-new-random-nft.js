// Add named accounts(hh config) and private key(in .env)
// Add helper hardhat config and development chains and network config(if any) in it.
// Add Contract verification Script
// Write deployment scripts.
const hre = require("hardhat");
const { deveplomentChains } = require("../helper-hardhat-config");

const { verify } = require("../utils/verify");
const fs = require("fs");

module.exports = async function ({ getNamedAccounts, deployments }) {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();


	log("------------------------Trying to Deploy-------------------------");

	const args = [];

	const newRandomNFT = await deploy("NEWRANDOMNFT", {
		from: deployer,
		log: true,
		args: args,
		waitConfirmations: network.config.blockConfirmations || 1,
	});

	console.log("----------------------Deployed Successfully----------------------");

	if (!deveplomentChains.includes(hre.network.name) && process.env.ETHERSCAN_API_KEY) {
		log("----------------------Trying to Verify the contract----------------------");
		await verify(newRandomNFT.address);
		log("----------------------Verified the Contract Successfully----------------------");
	}
};

module.exports.tags = ["all", "newRandomNFT"];
