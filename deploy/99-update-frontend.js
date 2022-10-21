const fs = require("fs");
const { ethers } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
require("dotenv").config();

const frontendContractFile = "../frontend-all-on-chain-nft/src/constants/networkMapping.json";
const frontendABILocation = "../frontend-all-on-chain-nft/src/constants/";


module.exports = async function () {
    if (process.env.UPDATE_FRONT_END == "true") {
        console.log("-------------------------------------------------------------------");
		console.log("Updating the Frontend...");
		await updateABI();
		await updateContractAddresses();
    }
}


async function updateABI() {
    const newRandomNFT = await ethers.getContract("NEWRANDOMNFT");
    console.log(newRandomNFT.address);
    fs.writeFileSync(
        `${frontendABILocation}newRandomNFT.json`,
        newRandomNFT.interface.format(ethers.utils.FormatTypes.json)
    );
}


async function updateContractAddresses() {
    const newRandomNFT = await ethers.getContract("NEWRANDOMNFT");
    const chainId = network.config.chainId.toString();
    const contractAddresses = JSON.parse(fs.readFileSync(frontendContractFile, "utf-8"));

    if (chainId in contractAddresses) {
		if (!contractAddresses[chainId]["NEWRANDOMNFT"].includes(newRandomNFT.address)) {
			contractAddresses[chainId]["NEWRANDOMNFT"].push(newRandomNFT.address);
		}
	} else {
		contractAddresses[chainId] = { NEWRANDOMNFT: [newRandomNFT.address] };
	}
	try {
		fs.writeFileSync(frontendContractFile, JSON.stringify(contractAddresses));
		console.log("Updated Frontned Successfully.");
		console.log("-------------------------------------------------------------------");
	} catch (error) {
		console.log(error);
	}
}