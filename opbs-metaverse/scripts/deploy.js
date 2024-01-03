// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const OPBS_METAVERSE = await hre.ethers.deployContract("OPBS_METAVERSE");

  const contract = await OPBS_METAVERSE.waitForDeployment();
  const deployTx = await contract.deploymentTransaction();


  console.log(
    `tx hash ${deployTx.hash}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
