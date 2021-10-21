
const { accounts, defaultSender, contract, web3, provider } = require('@openzeppelin/test-environment');
const { expect } = require("chai");
const { BN, expectEvent, time, expectRevert } = require('@openzeppelin/test-helpers');

const TokAuStarry = contract.fromArtifact("TokAuStarry");
const StarryBatchMintTransferHelper = contract.fromArtifact("StarryBatchMintTransferHelper");

describe("helper tests", () => {
    const [admin, user1, user2, hacker] = accounts;
    
    beforeEach(async () => {
        this.starry = await TokAuStarry.new({ from: admin });
        this.helper = await StarryBatchMintTransferHelper.new(this.starry.address, { from: admin });
    });

    it("helper utils test", async () => {
        await this.starry.grantRole(web3.utils.soliditySha3("MINTER_ROLE"), this.helper.address, { from: admin });
        await this.helper.batchMint([user1, user1], [new BN(1), new BN(2)], { from: admin });
        expect(await this.starry.ownerOf(new BN(1))).to.be.equal(user1);
        expect(await this.starry.ownerOf(new BN(2))).to.be.equal(user1);

        await this.starry.setApprovalForAll(this.helper.address, true, { from: user1 });
        await this.helper.batchTransfer(user1, [user2, user2], [1, 2], { from: admin });
        expect(await this.starry.ownerOf(1)).to.be.equal(user2);
        expect(await this.starry.ownerOf(2)).to.be.equal(user2);
    });
});