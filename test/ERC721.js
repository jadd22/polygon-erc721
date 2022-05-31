const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721 Contract", function () {
  let ERC721, myNFT, tokenName, tokenSymbol;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async () => {
    const tokenName = "My NFT";
    const tokenSymbol = "MFT";
    ERC721 = await ethers.getContractFactory("ERC721");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    myNFT = await ERC721.deploy(tokenName, tokenSymbol);
  });

  describe("Token Name and Symbol", async () => {
    it("Should assign name and symbol", async function () {
      // console.log(myNFT.address);
      expect(await myNFT.name()).to.equal("My NFT");
      expect(await myNFT.symbol()).to.equal("MFT");
    });
  });

  describe("Mint NFT", async () => {
    it("Should mint and assign ownership to owner", async () => {
      let tokenId = 1;
      let txHash = await myNFT.MintTokens(owner.address, tokenId);
      let ownerAddress = await myNFT.ownerOf(tokenId);
      console.log(ownerAddress);
      expect(ownerAddress).to.equals(owner.address.toString());
    });
  });

  describe("Transfer NFT", async () => {
    it("Transfer NFT Ownership to new owner", async() => {

      let tokenId = 1;
      let txHash = await myNFT.MintTokens(owner.address, tokenId);
      let ownerAddress = await myNFT.ownerOf(tokenId);
      let receiverAddress = addr1.address;
      console.log("Addres");
      console.log(ownerAddress,receiverAddress);
      //await myNFT.safeTransferFrom(ownerAddress,receiverAddress,tokenId);
      await myNFT["safeTransferFrom(address,address,uint256)"](ownerAddress,receiverAddress,tokenId);

      let newOwner = await myNFT.ownerOf(tokenId);

      expect(newOwner).to.equals(receiverAddress.toString());

    });

  });
});


describe("ERC721 Gas Optimized Contract", function () {
  let myContract, myNFT, tokenName, tokenSymbol;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async () => {
    const tokenName = "My NFT";
    const tokenSymbol = "MFT";
    myContract = await ethers.getContractFactory("ERC721GasOp");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    myNFT = await myContract.deploy(tokenName, tokenSymbol);
  });

  describe("Token Name and Symbol", async () => {
    it("Should assign name and symbol", async function () {
      // console.log(myNFT.address);
      expect(await myNFT.name()).to.equal("My NFT");
      expect(await myNFT.symbol()).to.equal("MFT");
    });
  });

  describe("Mint NFT - ERC721", async () => {
    it("Should mint and assign ownership to owner", async () => {
      let quantity = 10;
      let txHash = await myNFT.DefaultMint(owner.address, quantity);
      let txReponse = await txHash.wait();
      console.log("Tx Hash");
      console.log(txReponse.gasUsed.toString());
      let ownerAddress = await myNFT.ownerOf(5);

      expect(ownerAddress).to.equals(owner.address.toString());
    });
  });

  describe("Mint NFT - ERC721 Gas Op", async () => {
    it("Should mint and assign ownership to owner", async () => {
      let quantity = 10;
      let txHash = await myNFT.MintBulk(owner.address, quantity);
      let txReponse = await txHash.wait();
      console.log("Tx Hash");
      console.log(txReponse.gasUsed.toString());
      console.log(owner.address);
      let mintedQuantity = await myNFT.balanceOf(owner.address);

      expect(mintedQuantity).to.equals(quantity);
    });
  });

});

