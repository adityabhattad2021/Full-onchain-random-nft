const { network, ethers } = require("hardhat");
const { deveplomentChains, networkConfig } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
require("dotenv").config()

const VFR_SUBSCRIPTION_FUND_AMOUNT = ethers.utils.parseEther("40");

module.exports = async function ({ getNamedAccounts, deployments }) {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	const chainId = network.config.chainId;

	log(`------Deployer is ${deployer}------------`);

	let vrfCoordinatorV2Address, subscriptionId,vrfCoordinatorV2Mock;

	if (deveplomentChains.includes(network.name)) {
		vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock");
		vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
		const transectionResponse = await vrfCoordinatorV2Mock.createSubscription();
		const transectionRecipt = await transectionResponse.wait(1);
		subscriptionId = transectionRecipt.events[0].args.subId;
		await vrfCoordinatorV2Mock.fundSubscription(
			subscriptionId,
			VFR_SUBSCRIPTION_FUND_AMOUNT
        );
        
	} else {
		vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"];
		subscriptionId = networkConfig[chainId]["subscriptionId"];
	}

	const callBackGasLimit = networkConfig[chainId]["callBackGasLimit"];
	const gasLane = networkConfig[chainId]["gasLane"];

	console.log(`-------------1---------${vrfCoordinatorV2Address}------------------------------`);
	console.log(`-------------2---------${gasLane}------------------------------`);
	console.log(`-------------3---------${callBackGasLimit}------------------------------`);

    /*
    0x5FbDB2315678afecb367f032d93F642f64180aa3
    0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D

    0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15
    0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15

    */
	const args = [vrfCoordinatorV2Address, gasLane, subscriptionId, callBackGasLimit];

	log("---------------------------Deploying NFT-----------------------------");
	const randomNFT = await deploy("RandomSVGNFT", {
		from: deployer,
		args: args,
		log: true,
		waitConfirmations: network.config.blockConfirmations || 1,
	});
    log("---------------------------Deployed  NFT-----------------------------");

    if (deveplomentChains.includes(network.name)) {  
        const addConsumerTransection = await vrfCoordinatorV2Mock.addConsumer(subscriptionId, randomNFT.address);
        await addConsumerTransection.wait(1);
    }
    

	if (!deveplomentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
		log("------------------------Trying to verify----------------------------");
		await verify(randomNFT.address, args);
		log("--------------------------Verification Successful------------------------");
	}
};


module.exports.tags = ["all", "randomNFT"];