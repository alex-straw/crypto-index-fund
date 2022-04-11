const { expect } = require('chai');

let _name = "Portfolio";
let _ticker = "FOLO";
let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
let _percentageHoldings = [40, 60];
let _ownerFee = 100;

async function createPortfolio(_name,_ticker,_tokenAddresses,_percentageHoldings,_ownerFee) {

    await portfolioFactory.create(_name,_ticker,_tokenAddresses,_percentageHoldings,_ownerFee);
}

async function attachPortfolio(_portfolioAddress) {
    // Create contract instance of 'Portfolio.sol' using address and known code.
    Portfolio = await ethers.getContractFactory("Portfolio");
    portfolio = await Portfolio.attach(_portfolioAddress);

    return portfolio;
}

describe('Portfolio Factory Testing', function () {
    before(async function () {
        // Deploy PortfolioFactory.sol
        PortfolioFactory = await ethers.getContractFactory('PortfolioFactory');
        portfolioFactory = await PortfolioFactory.deploy();

        await createPortfolio(_name,_ticker,_tokenAddresses,_percentageHoldings,_ownerFee);
        portfolio = await attachPortfolio(await portfolioFactory.portfolios(0));

        // Log the addresses to the terminal for debugging
        console.log("Portfolio factory address:", portfolioFactory.address);
        console.log("Portfolio address: ", portfolio.address);
    });

    it('has successfully deployed a portfolio', async function () {
        // Verify by calling a portfolio function
        let supply = await portfolio.totalSupply.call();
        console.log('total supply: ', supply)
        expect(parseInt(await supply)).to.equal(0);
    });

    it('has successfully deployed a second portfolio', async function () {
        await createPortfolio(_name,_ticker,_tokenAddresses,_percentageHoldings,_ownerFee);
        portfolio_2 = await attachPortfolio(await portfolioFactory.portfolios(1));
        let supply = await portfolio_2.totalSupply.call();
        console.log('total supply: ', supply)
        expect(parseInt(await supply)).to.equal(0);
    });
});