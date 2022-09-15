# Keychain

This is a small project inspired by a tweet [@LEVXeth](https://twitter.com/LEVXeth) made.

## Inspiration

His private key was comprised, which left any contracts he had ownership of vulnerable to the attacker as well. As a solution he wrote [this](https://twitter.com/LEVXeth/status/1570320970287820800?s=20&t=znHqY5qyF-mwUHzQ8CTqXA). His framework would allow any contract that inherits `NFTOwned` to be owned by an `Ownership` NFT. If the NFT owner's private key was comprimised they could potentially recover contract ownership simply by transfering their token to another address (using Flashbots or something).

## Improvements

While his idea is 🔥, his implementation has a few limitations. First, it's only useful for contracts built in the future as it requires a contract to inherit `NFTOwned`. Keychain works a bit differently:

1) anyone can mint a `key` and pass their contract ownership to the `keychain`

2) a `key` can be used to open a `door` (call an access controlled contract) using `keychain.execute()`

This means you wouldn't have to redeploy existing contracts. Additionally, `keychain` allows a user to recover authorization by signing a transfer off-chain using EIP-712 and using another account to relay the meta-transaction.