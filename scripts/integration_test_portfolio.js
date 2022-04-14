const { expect } = require('chai');

// Portfolio constructor arguments
let _name = "Portfolio";
let _ticker = "FOLO";
let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
let _percentageHoldings = [50, 50];
let _owner = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1"
let _ownerFee = 10;

// Testing variables
const OWNER = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1"
const INITIALISE_AMOUNT = "100000"
const INITIAL_MINT_QTY = 100000000000000000000
const BUY_AMOUNT = "10000"
const TOKENS_TO_SELL = "20000000000000000000"

async function getAssetQuantities() {
    currentAssetQuantities = []
    for (let i = 0; i < _tokenAddresses.length; i++) {
        currentAssetQuantities.push(parseInt(await portfolio.assetQuantities(_tokenAddresses[i])))
    }
    return currentAssetQuantities
}

describe('DEPLOY', function () {

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
        expect(parseInt(supply)).to.equal(0);
    });

    describe('TEST: initialisePortfolio()', function () {
        before(async function () {
            await portfolio.initialisePortfolio({value:INITIALISE_AMOUNT});
        });

        it(`Has a total supply of ${INITIAL_MINT_QTY}`, async function () {
            let supply = await portfolio.totalSupply.call();
            expect(parseInt(supply)).to.equal(INITIAL_MINT_QTY);
        });

        it('Has correctly assigned owner to the associated hardhat config address', async function () {
            let owner = await portfolio.owner.call();
            expect(owner.toString()).to.equal(OWNER);
        })

        it("Has purchased ERC20s from Uniswap after calling 'initialisePortfolio()'", async function() {        
            let currentAssetQuantities = await getAssetQuantities(); 
            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(currentAssetQuantities[i]).to.be.greaterThan(0);
            }
        });
    });

    describe('TEST: buy()', function () {
        it("Has purchased ERC20s from Uniswap after calling 'buy()'", async function() {    

            let previousAssetQuantities = await getAssetQuantities();

            await portfolio.buy({value:BUY_AMOUNT});

            let currentAssetQuantities = await getAssetQuantities();

            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(currentAssetQuantities[i]).to.be.greaterThan(previousAssetQuantities[i]);
            }
        });

        it(`Supply of FOLO is greater than ${INITIAL_MINT_QTY} (tokens were correctly minted)`, async function() {
            let supply = await portfolio.totalSupply.call();
            expect(parseInt(supply)).to.be.greaterThan(INITIAL_MINT_QTY);
        });
    });

    describe('TEST: redeemAssets()', function () {
        it("Has transferred assets correctly to the user and burned FOLO tokens", async function() {    

            let previousAssetQuantities = await getAssetQuantities();
            let previousSupply = await portfolio.totalSupply.call()

            await portfolio.redeemAssets(TOKENS_TO_SELL);

            let currentAssetQuantities = await getAssetQuantities();
            let currentSupply = await portfolio.totalSupply.call()

            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(currentAssetQuantities[i]).to.be.lessThan(previousAssetQuantities[i]);
            }
            expect(parseInt(currentSupply)).to.equal((parseInt(previousSupply))-TOKENS_TO_SELL)
        });
    });

    describe('TEST: sellAssets()', function () {
        it("Has sold assets correctly, transferred ETH to the user, and burned FOLO tokens", async function() {    

            let previousAssetQuantities = await getAssetQuantities();
            let previousSupply = await portfolio.totalSupply.call()

            await portfolio.sellAssets(TOKENS_TO_SELL);

            let currentAssetQuantities = await getAssetQuantities();
            let currentSupply = await portfolio.totalSupply.call()

            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(currentAssetQuantities[i]).to.be.lessThan(previousAssetQuantities[i]);
            }
            expect(parseInt(currentSupply)).to.equal((parseInt(previousSupply))-TOKENS_TO_SELL)
        });
    });
});