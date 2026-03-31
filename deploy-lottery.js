const hre = require("hardhat");

async function main() {
  const VRF_COORDINATOR = "0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B"; // Sepolia
  const SUB_ID = "YOUR_SUBSCRIPTION_ID";

  const Lottery = await hre.ethers.getContractFactory("VerifiableLottery");
  const lottery = await Lottery.deploy(SUB_ID, VRF_COORDINATOR);

  await lottery.waitForDeployment();
  console.log("Verifiable Lottery deployed to:", await lottery.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
