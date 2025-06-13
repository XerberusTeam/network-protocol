# Xerberus Network Parameters

## Table of Contents

- [Introduction](#introduction)
- [Validator Keys](#validator-keys)
  - [Aura Keys (Block Production)](#aura-keys-block-production)
  - [Grandpa Keys (Block Finalization)](#grandpa-keys-block-finalization)
- [Chain Specification Configuration](#chain-specification-configuration)
- [Usage Guidelines](#usage-guidelines)

## Introduction

This document contains the cryptographic keys and network parameters for configuring the Xerberus blockchain network. These parameters are primarily used for local testnet setup and testing.

**IMPORTANT**: In a production environment, never share or expose these keys!

## Validator Keys

### Aura Keys (Block Production)

Aura keys use the Sr25519 cryptographic scheme and are used for block production.

#### Validator 1 - Aura

```
"accountId": "0xde947f4d9e0569e189f173c2cc9e85ac3dcc14c60e9cd6f3e254158efd45da0e",
"networkId": "substrate",
"publicKey": "0xde947f4d9e0569e189f173c2cc9e85ac3dcc14c60e9cd6f3e254158efd45da0e",
"secretPhrase": "candy cushion purse birth hint hero lens frown intact hope gesture toe",
"secretSeed": "0xd68bf4c12328ce388c2dff3fa192c33495e6ca72a06ddc654042a920aef361af",
"ss58Address": "5H6YbnEgCPAmvVNpWGXo1qbC7vEP28GHsvAyZzcBKG7rxfZg",
"ss58PublicKey": "5H6YbnEgCPAmvVNpWGXo1qbC7vEP28GHsvAyZzcBKG7rxfZg"
```

#### Validator 2 - Aura

```
"accountId": "0xb42291db975f6ac6758771400c5ecbc2cd151ddb293de6cead5908b303079d23",
"networkId": "substrate",
"publicKey": "0xb42291db975f6ac6758771400c5ecbc2cd151ddb293de6cead5908b303079d23",
"secretPhrase": "family stuff wreck snow lazy cannon used liar balcony solid crop pencil",
"secretSeed": "0x94ccd10a6bb3983276b9a352bb16da446dea364c4759c3c8d250abe21cdd36aa",
"ss58Address": "5G8tkD2M2NZZQxgihgWyYS9wX1Jh4Kuyk4KxRXDwnYiCKfxg",
"ss58PublicKey": "5G8tkD2M2NZZQxgihgWyYS9wX1Jh4Kuyk4KxRXDwnYiCKfxg"
```

#### Validator 3 - Aura

```
"accountId": "0x748cde0debf353773f6a7746f80be59e1ec85174cba9099a87eaca98f84d1505",
"networkId": "substrate",
"publicKey": "0x748cde0debf353773f6a7746f80be59e1ec85174cba9099a87eaca98f84d1505",
"secretPhrase": "essence adjust east all nuclear crowd before much tenant frog table sick",
"secretSeed": "0x22851646154d9e853be3b401df17fe1f682bbd41e60c7d049822c18167f38cc7",
"ss58Address": "5EhXFven9RKcRjpJVziP8ZNZsqdzARLE3AMfLGxkZTKhG2L7",
"ss58PublicKey": "5EhXFven9RKcRjpJVziP8ZNZsqdzARLE3AMfLGxkZTKhG2L7"
```

### Grandpa Keys (Block Finalization)

Grandpa keys use the Ed25519 cryptographic scheme and are used for block finalization.

#### Validator 1 - Grandpa

```
"accountId": "0xf5d53040be5faccea4e810727e4052c9ba9058b949a35f52e8a3c783603db516",
"networkId": "substrate",
"publicKey": "0xf5d53040be5faccea4e810727e4052c9ba9058b949a35f52e8a3c783603db516",
"secretPhrase": "field shed clown easy junk jeans before already time actual chimney relax",
"secretSeed": "0x4a4ed8696c52b1eb4289c9e3f60f546c4be05e6894ad687cdf4070cd2fa65d11",
"ss58Address": "5Hd2vGBRbJiphJEGig2BNi2RcLnddyUGHBXtQq9HANReUzvh",
"ss58PublicKey": "5Hd2vGBRbJiphJEGig2BNi2RcLnddyUGHBXtQq9HANReUzvh"
```

#### Validator 2 - Grandpa

```
"accountId": "0x614221ebd595c221f8395ccf5efd489d399cfb970f0cb7754bf02808d681c8d0",
"networkId": "substrate",
"publicKey": "0x614221ebd595c221f8395ccf5efd489d399cfb970f0cb7754bf02808d681c8d0",
"secretPhrase": "view defense shoot open spin mammal dune item buffalo wool suit truly",
"secretSeed": "0x82f3c316f961dfcdf531634a19341f035ea5d172e1a41383cae1d388c648c3db",
"ss58Address": "5EGE9WDq4TucU1mvPzHgrYG2zTMKk6zAtFJd5TQwpjiNMg9c",
"ss58PublicKey": "5EGE9WDq4TucU1mvPzHgrYG2zTMKk6zAtFJd5TQwpjiNMg9c"
```

#### Validator 3 - Grandpa

```
"accountId": "0x1bea0d82a952f7775985438e79aabf4f05db8c04a24e6328438a13c3f6e6ea23",
"networkId": "substrate",
"publicKey": "0x1bea0d82a952f7775985438e79aabf4f05db8c04a24e6328438a13c3f6e6ea23",
"secretPhrase": "border guide list vanish draw true announce derive sort struggle eyebrow grow",
"secretSeed": "0x6363d867eb45950e22ffb624706b4832227f326f9a6c7c1d23949d98b6c04a6e",
"ss58Address": "5ChJgHsHsS9L1CnmGmoTugKgoyPJ2TevALjY1wQSxMEpQG8B",
"ss58PublicKey": "5ChJgHsHsS9L1CnmGmoTugKgoyPJ2TevALjY1wQSxMEpQG8B"
```

## Chain Specification Configuration

When creating your chain specification (`chain-spec.json`), use the following formats:

### Aura Authorities Configuration

```json
"aura": {
  "authorities": [
    "5H6YbnEgCPAmvVNpWGXo1qbC7vEP28GHsvAyZzcBKG7rxfZg",
    "5G8tkD2M2NZZQxgihgWyYS9wX1Jh4Kuyk4KxRXDwnYiCKfxg",
    "5EhXFven9RKcRjpJVziP8ZNZsqdzARLE3AMfLGxkZTKhG2L7"
  ]
},
```

### Grandpa Authorities Configuration

```json
"grandpa": {
  "authorities": [
    [
      "5Hd2vGBRbJiphJEGig2BNi2RcLnddyUGHBXtQq9HANReUzvh",
      1
    ],
    [
      "5EGE9WDq4TucU1mvPzHgrYG2zTMKk6zAtFJd5TQwpjiNMg9c",
      1
    ],
    [
      "5ChJgHsHsS9L1CnmGmoTugKgoyPJ2TevALjY1wQSxMEpQG8B",
      1
    ]
  ]
},
```

### Balances Configuration

For initial token distribution (optional):

```json
"balances": {
  "balances": [
    [
      "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY",
      1152921504606846976
    ],
    [
      "5H6YbnEgCPAmvVNpWGXo1qbC7vEP28GHsvAyZzcBKG7rxfZg",
      1152921504606846976
    ],
    [
      "5G8tkD2M2NZZQxgihgWyYS9wX1Jh4Kuyk4KxRXDwnYiCKfxg",
      1152921504606846976
    ],
    [
      "5EhXFven9RKcRjpJVziP8ZNZsqdzARLE3AMfLGxkZTKhG2L7",
      1152921504606846976
    ],
    [
      "5Hd2vGBRbJiphJEGig2BNi2RcLnddyUGHBXtQq9HANReUzvh",
      1152921504606846976
    ],
    [
      "5EGE9WDq4TucU1mvPzHgrYG2zTMKk6zAtFJd5TQwpjiNMg9c",
      1152921504606846976
    ],
    [
      "5ChJgHsHsS9L1CnmGmoTugKgoyPJ2TevALjY1wQSxMEpQG8B",
      1152921504606846976
    ]
  ]
},
```

## Usage Guidelines

1. Insert the keys into your validators using the RPC calls documented in the [Node Setup Guide](../node/node-setup-guide.md)
2. Add the SS58 addresses to your chain spec file before generating the raw spec
3. Keep the secret phrases secure - they're needed to restore keys if needed
4. The keys are referred to in `insertKey` commands by their secret phrases or seeds

---

## Related Resources

- [Node Setup Guide](../node/node-setup-guide.md)
- [Testnet Configuration](../node/testnet-configuration.md) 