const {time} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const hre = require("hardhat");


describe("Prime", function () {

  describe("Prime deployment", function () {
    it("Should mint 1000 tokens", async () => {
      const [owner] = await ethers.getSigners();

      const Prime = await ethers.getContractFactory("Prime");
      const prime = await Prime.deploy("PRIME", "PRI");

      expect(await prime.balanceOf(owner.address)).to.equal(hre.ethers.utils.parseUnits("1000", 18));
    });
  });

  describe("Vault", async function () {
    let owner, user, prime, vault, pusd;

    beforeEach("Deploy all contracts before testing", async () => {
      [owner, user] = await ethers.getSigners();

      const Prime = await ethers.getContractFactory("Prime");
      prime = await Prime.deploy("Prime", "PRI");

      const Vault = await ethers.getContractFactory("Vault");
      vault = await Vault.deploy()

      const PUSD = await ethers.getContractFactory("PUSD");
      pusd = await PUSD.deploy("primeUSD", "PUSD", vault.address);

      await vault.setPUSD(pusd.address);
      await vault.setPrime(prime.address);
    });
    
    it("Should accrue interest", async () => {
      await prime.approve(user.address, 1000);
      await prime.transfer(user.address, 1000);

      await prime.connect(user).approve(vault.address, 900)
      await vault.connect(user).depositPrime(900);

      await time.increase(365*24*60*60);

      expect(await vault.getRewards(user.address)).to.equal(9);
    });

    it("Should be able to withdraw PUSD", async () => {
      await prime.approve(user.address, 1000);
      await prime.transfer(user.address, 1000);

      await prime.connect(user).approve(vault.address, 900)
      await vault.connect(user).depositPrime(900);

      await time.increase(365*24*60*60);

      //Mine multiple blocks
      for (let i = 0; i<10; i++){
        await time.increase(10);
      }

      await vault.connect(user).claimRewards(8);

      expect(await pusd.balanceOf(user.address)).to.equal(8);
    });
  });
});

