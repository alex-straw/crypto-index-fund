const { expect } = require('chai');

let _name = "Portfolio";
let _ticker = "FOLO";
let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
let _percentageHoldings = [40, 60];
let _ownerFee = 100;

async function attachPortfolio(_portfolioAddress) {
    // Create contract instance of 'Portfolio.sol' using its address and solidity code
    Portfolio = await ethers.getContractFactory("Portfolio");
    _portfolio = await Portfolio.attach(_portfolioAddress);
    return _portfolio;
}

describe('Portfolio Factory Testing', function () {
    before(async function () {
        // Deploy PortfolioFactory.sol. Only needs to be performed once
        PortfolioFactory = await ethers.getContractFactory('PortfolioFactory');
        portfolioFactory = await PortfolioFactory.deploy();
    })
    
    beforeEach(async function () {
        await portfolioFactory.create(_name,_ticker,_tokenAddresses,_percentageHoldings,_ownerFee);
    });

    it('has successfully deployed a portfolio', async function () {
        // Check that the 'portfolios' array has a valid portfolio address in index 0
        let portfolio = await attachPortfolio(portfolioFactory.portfolios(0));
        let supply = await portfolio.totalSupply.call();
        expect(parseInt(supply)).to.equal(0);
    });

    it('has successfully deployed a second portfolio', async function () {
        // Check that the 'portfolios' array has a valid portfolio address in index 1
        let portfolio2 = await attachPortfolio(portfolioFactory.portfolios(1));
        let supply = await portfolio2.totalSupply.call();
        expect(parseInt(supply)).to.equal(0);
    });
});