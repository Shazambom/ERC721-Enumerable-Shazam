## Introducing ERC721EnumerableS!
This is an experiment to see if I can optimize the ERC721 NFT Extension ERC721Enumerable. 

When minting multiple NFTs this new version of the ERC721Enumerable extension **reduces gas price by around 400%**

However, this implementation does come with some caveats
 -
 - This implemention abuses the `view` functions in the interface
 - This means the actual implemented functions may not nessesarily be more gas efficient than the [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol) implementation
 - In fact OpenZeppelin's functions only require O(1) to retreive their data in their contracts where as this implementation generally requires O(N) operations

So how is this implementation better?
-
In general these "read only" `view` functions aren't called within other contracts, they are called by DAPPs that use contracts as their API. As long as these interface functions aren't called outside of a `view` context in solidity **they incur 0 gas fees**. Therefore, we are getting the same functionality as ERC721Enumerable at **1/4th the mint cost**. 

## Note
This is a work in progress, feedback is welcome!

## Contribution guide
This repo uses [foundry](https://book.getfoundry.sh/index.html) for its testing/dev environment, please submit all tests in solidity.
