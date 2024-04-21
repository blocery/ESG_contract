import { ethers } from "hardhat";

async function main() {

    const BLY = await ethers.getContractFactory("BLY");
    const BLYStaking = await ethers.getContractFactory("BLYStaking");
    const ESGPassOrg = await ethers.getContractFactory("ESGPassOrg");
    const ESGPassUser = await ethers.getContractFactory("ESGPassUser");

    const owner = await ethers.provider.getSigner("0x4827a7cAB9F53f34CAC0D88749BeB875AabEeD4E")
    //const bly = await BLY.connect(owner).deploy();
    const bly = await BLY.attach("0x52FEAb470eb604CdAA0eBFf6Dbe11764cA245e03")
    //const epO= await ESGPassOrg.connect(owner).deploy("ESGPass for Orginization", "ESGPass")
    const epO = await ESGPassOrg.attach("0x9B86380ba4278c486d7f4eE679634ddA9b05FE39")
    //const epU = await ESGPassUser.connect(owner).deploy("ESGPass for Orginization", "ESGPass")
    const threshold = ethers.parseEther("10000")
    const staking = await BLYStaking.deploy(await epO.getAddress(), await bly.getAddress(), threshold);
    //const staking = await BLYStaking.attach("0x0a682853fcf11213b3c53D12dEF4C4975f1eca1A")

    const MINTROLE = await epO.MINTROLE()
    await epO.connect(owner).grantRole(MINTROLE, await staking.getAddress())

    console.log("bly", await bly.getAddress())
    console.log("esg for org", await epO.getAddress())
    //console.log("esg for user", await epU.getAddress())
    console.log("staking", await staking.getAddress())
    /*
     * bly 0x52FEAb470eb604CdAA0eBFf6Dbe11764cA245e03
     * esg for org 0x9B86380ba4278c486d7f4eE679634ddA9b05FE39
     * esg for user 0x95aC5109912da7B5203e885f55607e698522bB5c
     * staking 0xd894A3D1Dc40F62D12300340e8C50C3E5aDE034F
     */

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
