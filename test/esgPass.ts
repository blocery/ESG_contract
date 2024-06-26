import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ESGPass", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAll() {

    // Contracts are deployed using the first signer/account by default
    const [owner, alice, bob] = await ethers.getSigners();

    const BLY = await ethers.getContractFactory("BLY");
    const BLYStaking = await ethers.getContractFactory("BLYStaking");
    const ESGPassOrg = await ethers.getContractFactory("ESGPassOrg");
    const ESGPassUser = await ethers.getContractFactory("ESGPassUser");
    const BLYFaucet = await ethers.getContractFactory("BLYFaucet");

    const bly = await BLY.connect(owner).deploy();
    const epO= await ESGPassOrg.connect(owner).deploy("ESGPass for Orginization", "ESGPass")
    const epU = await ESGPassUser.connect(owner).deploy("ESGPass for Orginization", "ESGPass")
    const threshold = ethers.parseEther("10000")
    const staking = await BLYStaking.deploy(await epO.getAddress(), await bly.getAddress(), threshold);
    const faucet = await BLYFaucet.deploy(await bly.getAddress(), 60)


    const MINTROLE = await epO.MINTROLE()
    await epO.connect(owner).grantRole(MINTROLE, await staking.getAddress())

    return { bly, epO, epU, staking, owner, alice, bob, faucet};
  }

  describe("Deployment", function () {
    it("it should success", async function () {
      const { bly, epO, epU, staking, owner, alice, bob} = await loadFixture(deployAll);

      const threshold = ethers.parseEther("10000");
      await bly.connect(owner).transfer(await alice.getAddress(), threshold);
      await bly.connect(alice).approve(await staking.getAddress(), threshold);
      await staking.connect(alice).stake(threshold);
      await staking.connect(alice).mint()
      const totalStakers = await staking.totalStakers()
        console.log(totalStakers)
      await expect(staking.connect(bob).mint()).revertedWith("Need to stake more BLY")
      await staking.connect(alice).burn(1);
      await staking.connect(alice).unstake(threshold)

    });

    it("it should success", async function () {
      const { bly,owner, alice, bob, faucet} = await loadFixture(deployAll);

      const threshold = ethers.parseEther("1000000000");
      await bly.connect(owner).transfer(await faucet.getAddress(), threshold);
      await faucet.connect(alice).claim()
      let balance = await bly.balanceOf(await alice.getAddress())
      await expect(faucet.connect(alice).claim()).revertedWith("claim limited")
      await time.increase(time.duration.minutes(4));
      await faucet.connect(alice).claim()
      balance = await bly.balanceOf(await alice.getAddress())
        console.log(balance)
    });

  });

});
