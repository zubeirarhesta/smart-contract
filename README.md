# Soonan Tsoor

## Orders Todo

### 1. Deploy with order

- Firstly deploy **TransferEth.sol** and **TokenContract.sol**, because they have any constructor to pass in,
- Then deploy **NFTContract.sol** with **TokenContract** address as constructor arg, because **NFTContract.**
needs to approve **TokenContract** in order to Fractionalized its NFTs,
- Lastly deploy **StakeSoonanTsool.sol** with **TokenContract** address as constructor arg, because **StakeSoonanTsool** needs **TokenContract** address in order to stake the ERC20/WSNSR token.

### 2. Initial Setup

- You need to *safeMintAll* the NFTs in **NFTContract**,
- then *createAllFraction* in **TokenContract** with **NFTContract** address as arg to pass in,
- finally, everytime you want to stake, you need to *approve* **StakeSoonanTsool**, by passing its address as arg, then specify the amount. Then you *stakeToken* in **StakeSoonanTsool** with the same or less amount
you fill before.