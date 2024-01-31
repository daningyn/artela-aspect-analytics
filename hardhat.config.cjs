module.exports = {
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    hardhat: {
      forking: {
        url: "https://betanet-rpc1.artela.network",
      },
    },
  }
};