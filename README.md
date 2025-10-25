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

#### Minimal proxy: EIP-1167

**Why it is important?**

- It is cheap to create copy of contracts, because the logic will not be in the creation code, it is only an address of
  the implementation, and delegatecalls everything
- The actual logic of the copy is just setting the target address plus a function to forward everything to the target

**How to?**

Create the bytecode: `[Creation code] + [Target address] + [Bytecode for forwarding]`

```solidity
function clone(address target) external returns (address result) {
    bytes20 targetBytes = bytes20(target); // Converts the address to bytes20

    assembly {
        // Make a variable ready to receive
        /*
         * Reads the 32bytes memory at 0x40, which is the pointer to current free mem, use it to load data into the memory
         *
         * More on 0x40:
         *
         * This is the designed way to access the end of currently allocated memory, to get to the position, Yul allows
         * using 0x40, so here we stored 32bytes of data to this location
         */
        let clone := mload(0x40)
        mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

        /*
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      pointer
			So to store 20bytes memory next, need to move pointer 20bytes
        */
        mstore(add(clone, 0x14), targetBytes)
        /*
		 * Now to store the runtime code, need to move 20bytes(creation code) + 20bytes(address) = 40bytes
		 */
        mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

        /*
		 * Now we get: 
		 *  |               20 bytes                 |                 20 bytes              |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
		 */

        /*
		 * Create contract:
		 * Send 0 ether
		 * Code start at location: clone
		 * Code size: 55 bytes
		 */
        result := create(0, clone, 0x37)
    }
}
```

In production, will be using OpenZeppelin to implement this

**OpenZeppelin implementation: contracts/proxy/Clones.sol**
*Q: How and why is it different from example above?*

##### Develop and deploy design

1. Develop and deploy `DappLinkVRFCore`, and deploy it, we will get a static address for all future copies to reference
2. Develop and deploy `ECDSARegistry` will be used to verify the submitted signatures
3. Develop and deploy `DappLinkVRFFactory`, to deploy copies

### Implementation

#### Factory

DappLinkVRF is using `Clone.clone` method, which is non-deterministic deployment, I might change it to use
`Clone.cloneDeterministic`, add upon creation, will require salt, so the proxy address will be known prior to the
deployment

#### VRF Core

The logic will stay the same: `requestRandomWords` for consumers to call, `fulfilRandomWords` for nodes to call

##### `requestRandomWords`

Called by consumers, exposed, will create `requestId` and event, register `requestId` in a mapping

##### `fulfilRandomWords`

Called by nodes, will verify based on submitted signatures, then update the mapping

#### `ECDSA`

Will use ECDSA to verify signatures, with ecdsa, will have to verify the signatures one by one, ecrecover will give us
the address, will have to check against verifier registry, key part of this is to sync off-chain signing with
verification here


