import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ESGPassOrg", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAll() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const ESGPASS = await ethers.getContractFactory("ESGPass");
    const esgPass = await ESGPASS.deploy();

    return { esgPass , owner, otherAccount };
  }

  describe("Deployment", function () {
    it("", async function () {
      const { esgPass , owner, otherAccount} = await loadFixture(deployAll);

    });

  });

});
