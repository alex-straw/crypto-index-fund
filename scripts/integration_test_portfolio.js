const { expect } = require('chai');

let _name = "Portfolio";
let _ticker = "FOLO";
let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
let _percentageHoldings = [40, 60];
let _owner = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1"
let _ownerFee = 100;

// Check variables
const OWNER = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1"
const INITIALISE_AMOUNT = "10000000000" 

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
        //await portfolio.initialisePortfolio({value:INITIALISE_AMOUNT});
    });

    it('has a total supply of 0', async function () {
        let result = await portfolio.totalSupply.call();
        console.log('total supply: ', result)
        expect(await result.toString()).to.equal("0");
    });

    describe('Initialisation testing', function () {
        before(async function () {
            await portfolio.initialisePortfolio({value:INITIALISE_AMOUNT});
        });


        it('has a total supply of 1000000000000000', async function () {
            let result = await portfolio.totalSupply.call();
            console.log('total supply: ', result)
            expect(await result.toString()).to.equal("100000000000000000000");
        });
    });
});