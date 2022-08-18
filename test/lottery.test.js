// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Lottery", function () {
  let lottery;

  beforeAll(async function () {
    const Lottery = await ethers.getContractFactory("Lottery");
    lottery = await Lottery.deploy();
    await lottery.deployed();
    console.log("lottery deployed at:" + lottery.address);
  });

  it("test initial value", async function () {
    expect((await lottery.retrieve()).toNumber()).to.equal(0);
  });

  it("test updating and retrieving updated value", async function () {
    const lottery2 = await ethers.getContractAt("Lottery", lottery.address);
    const setValue = await lottery2.store(56);
    await setValue.wait();
    expect((await lottery2.retrieve()).toNumber()).to.equal(56);
  });

  it("enters a bearer into the lottery pool", async function () {});
});
