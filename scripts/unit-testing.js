// We import Chai to use its asserting functions here.
const { expect } = require("chai");

describe("Token contract", function () {
    let Portfolio;
    let hardhatPortfolio;
    let owner;

    let _name = "Portfolio";
    let _ticker = "FOLO";
    let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
    let _percentageHoldings = [40, 60];
    let _owner = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1";
    let _ownerFee = 100;

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        Portfolio = await ethers.getContractFactory("Portfolio");
        [owner] = await ethers.getSigners();

        hardhatPortfolio = await Portfolio.deploy(
            _name,
            _ticker,
            _tokenAddresses,
            _percentageHoldings,
            _owner,
            _ownerFee);
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await hardhatPortfolio.owner()).to.equal(_owner);
        });
    });
});