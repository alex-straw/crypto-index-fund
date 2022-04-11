const { expect } = require('chai');

// Portfolio constructor arguments
let _name = "Portfolio";
let _ticker = "FOLO";
let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
let _percentageHoldings = [40, 60];
let _owner = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1"
let _ownerFee = 100;

// Testing variables
const OWNER = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1"
const INITIALISE_AMOUNT = "10000000000" 
const BUY_AMOUNT = "20000000000"

async function getAssetQuantities() {
    currentAssetQuantities = []
    for (let i = 0; i < _tokenAddresses.length; i++) {
        currentAssetQuantities.push(parseInt(await portfolio.assetQuantities(_tokenAddresses[i])))
    }
    return currentAssetQuantities
}


describe('Integration test for portfolio', function () {

    before(async function () {

        Portfolio = await ethers.getContractFactory('Portfolio');
        portfolio = await Portfolio.deploy(
            _name,
            _ticker,
            _tokenAddresses,
            _percentageHoldings,
            _owner,
            _ownerFee
        );
        await portfolio.deployed();
    });

    it('Has a total supply of 0', async function () {
        let supply = await portfolio.totalSupply.call();
        expect(await supply.toString()).to.equal("0");
    });

    describe('TEST: Initialise Portfolio', function () {
        before(async function () {
            await portfolio.initialisePortfolio({value:INITIALISE_AMOUNT});
        });

        it('Has a total supply of 1000000000000000', async function () {
            let supply = await portfolio.totalSupply.call();
            expect(await supply.toString()).to.equal("100000000000000000000");
        });

        it('Has correctly assigned owner to the associated hardhat config address', async function () {
            let owner = await portfolio.owner.call();
            expect(await owner.toString()).to.equal(OWNER);
        })

        it("Has purchased ERC20s from Uniswap after calling 'initialisePortfolio()'", async function() {     
            let AssetQuantities = await getAssetQuantities()
    
            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(await currentAssetQuantities[i]).to.be.greaterThan(0);
                console.log(_tokenAddresses[i],", Quantity : ", currentAssetQuantities[i])
            }
        });
    });

    describe('TEST: Buy', function () {
        it("Has purchased ERC20s from Uniswap after calling 'buy()'", async function() {    
            let previousAssetQuantities = await getAssetQuantities();
            await portfolio.buy({value:BUY_AMOUNT});
            let currentAssetQuantities = await getAssetQuantities();

            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(await currentAssetQuantities[i]).to.be.greaterThan(previousAssetQuantities[i]);
                console.log(_tokenAddresses[i],", Quantity : ", currentAssetQuantities[i])
            }
        });
    });
});