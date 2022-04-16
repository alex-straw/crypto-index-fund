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
const BUY_AMOUNT = "34000"
const TOKENS_TO_SELL = "5000000000000000000"

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

        it(`Has a total FOLO supply of ${INITIAL_MINT_QTY}`, async function () {
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

        before(async function() {
            previousAssetQuantities = await getAssetQuantities();
        })

        it("Has emitted an event after calling 'buy()'", async function() {
            await expect(portfolio.buy({value:BUY_AMOUNT}))
                .to.emit(portfolio, 'Buy');
                // (msg.sender, msg.value, priorValueLocked, tokensToMint - ownerTokens)
        });

        it("Has purchased ERC20s from Uniswap after calling 'buy()'", async function() {    
            let currentAssetQuantities = await getAssetQuantities();
            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(currentAssetQuantities[i]).to.be.greaterThan(previousAssetQuantities[i]);
            }
        });

        it(`Has a total FOLO supply greater than ${INITIAL_MINT_QTY} (tokens were minted)`, async function() {
            let supply = await portfolio.totalSupply.call();
            expect(parseInt(supply)).to.be.greaterThan(INITIAL_MINT_QTY);
        });
    });

    describe('TEST: redeemAssets()', function () {

        before(async function () {
            previousAssetQuantities = await getAssetQuantities();
            previousSupply = await portfolio.totalSupply.call()
            
            expectedNewQuantities = []
            for (let i = 0; i < previousAssetQuantities.length; i++) {
                expectedNewQuantities.push(previousAssetQuantities[i]-Math.floor(previousAssetQuantities[i] * TOKENS_TO_SELL / previousSupply))
            };
        });

        it("Has emitted an event after calling 'redeemAssets()'", async function() {
            await expect(portfolio.redeemAssets(TOKENS_TO_SELL))
                .to.emit(portfolio, 'RedeemAssets');
                // (msg.sender, tokensToSell)
        });

        it("Has transferred the expected quantities of each asset to the sender", async function() {    
            currentAssetQuantities = await getAssetQuantities();
            currentSupply = await portfolio.totalSupply.call()

            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(currentAssetQuantities[i]).to.equal(expectedNewQuantities[i]);
            }
        });

        it(`Has decreased the FOLO supply by: ${TOKENS_TO_SELL} (tokens were burned)`, async function() {
            expect(parseInt(currentSupply)).to.equal((parseInt(previousSupply))-TOKENS_TO_SELL)
        });
    });

    describe('TEST: sellAssets()', function () {
        
        before(async function () {
            previousAssetQuantities = await getAssetQuantities();
            previousSupply = await portfolio.totalSupply.call()

            expectedNewQuantities = []
            for (let i = 0; i < previousAssetQuantities.length; i++) {
                expectedNewQuantities.push(previousAssetQuantities[i]-Math.floor(previousAssetQuantities[i] * TOKENS_TO_SELL / previousSupply))
            };
        })

        it("Has emitted an event after calling 'sellAssets()'", async function() {
            await expect(portfolio.sellAssets(TOKENS_TO_SELL))
                .to.emit(portfolio, 'SellAssets');
                // (msg.sender, tokensToSell, wethAcquired)
        });

        it("Has sold assets correctly, transferred ETH to the user, and burned FOLO tokens", async function() {    
            currentAssetQuantities = await getAssetQuantities();
            currentSupply = await portfolio.totalSupply.call()

            for (let i = 0; i < _tokenAddresses.length; i++) {
                expect(currentAssetQuantities[i]).to.equal(expectedNewQuantities[i]);
            }
        });
        
        it(`Has decreased the FOLO supply by: ${TOKENS_TO_SELL} (tokens were burned)`, async function() {
            expect(parseInt(currentSupply)).to.equal((parseInt(previousSupply))-TOKENS_TO_SELL)
        });
    });
});