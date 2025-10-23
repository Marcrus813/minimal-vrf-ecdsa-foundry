# Day 17 Assignment

Content:

```markdown
# 第十七天的作业

## 第一题

- 基础作业：用最小代理实现一个随机数的提交和链上使用，每一个项目开一个逻辑一致的最小代理合约，最小代理合约创建处理之后添加到一个管理合约，管理合约管理所有代理合约，部署合约使用
  create2 的方式进行部署？
- 加强版：使用 ECDSA 的算法进行链下提交上来的随机的有，真实性和效性验证（挑战性）

## 第二题： - 将历史上发生重入攻击项目整理出来，并写出被攻击逻辑和攻击 POC （扩展题）

## 参考代码：https://github.com/the-web3-contracts/dapplink-vrf-contracts
```

## Q1

### To understand:

- [ ] EIP-1167
- [ ] create2
- [ ] How do VRF oracles work? Mainly, how to verify the submitted results? How do cryptography come in?
    - [ ] BLS
    - [ ] ECDSA

#### VRF Process and BLS

The process:

1. Consumer calls Oracles's `requestRandomWords`, creating a `requestId` for future use
2. Oracle broadcasts the event for nodes to receive
3. Nodes calculates and passes the data back to the oracle
4. Oracle verifies data received.
5. Oracle calls consumer's `fulfilRandomWords` to continue trigger consumer's logic

BLS Aspect of the process:

1. When generating data, the manager generates, and the rest of nodes are there to sign if they think the data is valid
2. The signing and verification is classic BLS

If to implement with ECDSA:

BLS enables the system to verify all signatures with one verification calculation, so if I were to use ECDSA, I need to
verify for all signers, with all the signers pre-registered
