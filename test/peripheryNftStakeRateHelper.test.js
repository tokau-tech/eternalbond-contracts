const { accounts, defaultSender, contract, web3, provider } = require('@openzeppelin/test-environment');
const { expect } = require("chai");
const { BN, expectEvent, time, expectRevert } = require('@openzeppelin/test-helpers');

// const StringUtils = contract.fromArtifact("StringUtils");
const EBNftStakeRateHelper = contract.fromArtifact("EBNftStakeRateHelper");
const TokAuStarry = contract.fromArtifact("TokAuStarry");

describe("periphery nft stake rate helper", () => {
    const [admin, user1, user2] = accounts;

    beforeEach(async () => {
        // this.utils = await StringUtils.new({ from: admin });
        this.starry = await TokAuStarry.new({ from: admin });

        // //use library should do this
        // await EBNftStakeRateHelper.detectNetwork();
        // await EBNftStakeRateHelper.link('StringUtils', this.utils.address);

        this.helper = await EBNftStakeRateHelper.new(this.starry.address, [100, 201], [15, 30], { from: admin });
    });

    it("test nft stake rate helper", async () => {
        expect(await this.helper.boostRate(this.starry.address, 100000001, { from: user1 })).to.be.bignumber.equal(new BN(15));
        expect(await this.helper.boostRate(this.starry.address, 201001301, { from: user1 })).to.be.bignumber.equal(new BN(30));
        expect(await this.helper.isStakeableNft(this.starry.address, 201001301, { from: user1 })).to.be.equal(true);

        await this.helper.updateToken(this.starry.address, [201, 227], [11, 22], { from: admin });
        expect(await this.helper.isStakeableNft(this.starry.address, 100000001, { from: user1 })).to.be.equal(false);
        expect(await this.helper.boostRate(this.starry.address, 201001301, { from: user1 })).to.be.bignumber.equal(new BN(11));
        expect(await this.helper.boostRate(this.starry.address, 227011231301, { from: user1 })).to.be.bignumber.equal(new BN(22));
        expect(await this.helper.isStakeableNft(this.starry.address, 227123123851901, { from: user1 })).to.be.equal(true);

    });
});