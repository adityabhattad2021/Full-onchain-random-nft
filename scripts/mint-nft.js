const fs = require("fs");
const {ethers,getNamedAccounts} = require("hardhat")

async function main() {
    console.log("---------------------------------------------------------------------");
    console.log("Trying to Create Sample NFT");
    const {deployer} = await getNamedAccounts()
    const sampleSVG = fs.readFileSync("./images/ChainlinkNFT.svg",{ encoding: "utf-8" });
    // console.log(sampleSVG);
    const sampleNFT = await ethers.getContract("SVGNFT",deployer)
    // console.log(sampleNFT.address);
    const tokenId=await sampleNFT.s_tokenCounter()
	const transectionResponse = await sampleNFT.create(sampleSVG)
	await transectionResponse.wait(1);
    
    console.log(`NFT Created Successfully, its token URI is ${await sampleNFT.tokenURI(tokenId)}`);
    console.log("---------------------------------------------------------------------");
    
}

main()
	.then(() => {
		process.exit(0);
	})
	.catch((error) => {
		console.log(error);
		process.exit(1);
	});
