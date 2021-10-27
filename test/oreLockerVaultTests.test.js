const { accounts, defaultSender, contract, web3, provider } = require('@openzeppelin/test-environment');
const { expect } = require("chai");
const { BN, expectEvent, time, expectRevert } = require('@openzeppelin/test-helpers');

const EBChef = contract.fromArtifact("EBChef");
const OreLockerVault = contract.fromArtifact("OreLockerVault");
const OreMinter = contract.fromArtifact("OreMinter");
const TokAuTreasures = contract.fromArtifact("TokAuTreasures");
const TokAu = contract.fromArtifact("TokAu");

describe("ore locker vault tests", () => {
    const [userAdmin, user1, user2] = accounts;
    const oreTokenId = new BN(1);
    const oreLockerVaultEmissionRate = new BN(1);

    beforeEach(async () => {
        this.ebChef = await EBChef.new({ from: userAdmin });
        this.oreLockerVault = await OreLockerVault.new({ from: userAdmin });
        this.oreMinter = await OreMinter.new({ from: userAdmin });

        this.tokau = await TokAu.new({ from: userAdmin });
        this.tokauTreasures = await TokAuTreasures.new({ from: userAdmin });

        await this.tokauTreasures.initialize("https://api-testnets.tokau.io/", { from: userAdmin });
        await this.tokauTreasures.grantRole(web3.utils.soliditySha3("MINTER_ROLE"), this.oreMinter.address, { from: userAdmin });
        await this.oreLockerVault.initialize(this.ebChef.address, this.tokau.address, oreTokenId, oreLockerVaultEmissionRate);
        await this.oreLockerVault.setLockerPeroids([new BN(60*60*24*7), new BN(60*60*24*14)], [new BN(100), new BN(125)]);
        await this.oreMinter.initialize(this.ebChef.address, this.tokauTreasures.address);
        await this.ebChef.initialize(new BN(0));
        await this.ebChef.setMinter(this.oreMinter.address);
        await this.ebChef.addVault(this.oreLockerVault.address);
    });

    it("single user approve, stake and withdraw", async () => {
        await this.tokau.approve(this.oreLockerVault.address, new BN(10).pow(new BN(33)), { from: user1 });
        await this.tokau.transfer(user1, new BN(10).pow(new BN(27)).mul(new BN(4)), { from: userAdmin });
        const user1StakeReceipt = await this.oreLockerVault.depositLocker(0, new BN(10).pow(new BN(27)), { from: user1 });
        expectEvent(user1StakeReceipt, "OreLockerVaultDeposited", { user: user1, period: new BN(60*60*24*7), amount: new BN(10).pow(new BN(27)) });
        expect(await this.oreLockerVault.totalAmount()).to.be.bignumber.equal(new BN(10).pow(new BN(27)));
        expect(await this.oreLockerVault.balance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(27)));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(0));
        
        const user1StakeReceipt1 = await this.oreLockerVault.depositLocker(1, new BN(10).pow(new BN(27)).mul(new BN(3)), { from: user1 });
        expectEvent(user1StakeReceipt1, "OreLockerVaultDeposited", { user: user1, period: new BN(60*60*24*14), amount: new BN(10).pow(new BN(27)).mul(new BN(3)) });
        expect(await this.oreLockerVault.totalAmount()).to.be.bignumber.equal(new BN(10).pow(new BN(27)).mul(new BN(4)));
        expect(await this.oreLockerVault.balance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(27)).mul(new BN(4)));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(0));
        
        await time.increase(time.duration.days(3));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(0));
        await time.increase(time.duration.days(4));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(27)));
        
        await time.increase(time.duration.days(3));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(27)));
        await expectRevert(this.oreLockerVault.withdraw(0, { from: user1 }), "invalid amount");
        const user1WithdrawReceipt = await this.oreLockerVault.withdraw(new BN(10).pow(new BN(26)), { from: user1 });
        expectEvent(user1WithdrawReceipt, "OreLockerVaultWithdrawn", { user: user1, amount: new BN(10).pow(new BN(26))});
        expect(await this.oreLockerVault.totalAmount()).to.be.bignumber.equal(new BN(10).pow(new BN(26)).mul(new BN(39)));
        expect(await this.oreLockerVault.balance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(26)).mul(new BN(39)));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(26)).mul(new BN(9)));

        await time.increase(time.duration.days(4));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(26)).mul(new BN(39)));
    });

    it("multi users", async() => {
        await this.tokau.approve(this.oreLockerVault.address, new BN(10).pow(new BN(33)), { from: user1 });
        await this.tokau.approve(this.oreLockerVault.address, new BN(10).pow(new BN(33)), { from: user2 });
        await this.tokau.transfer(user1, new BN(10).pow(new BN(27)), { from: userAdmin });
        await this.tokau.transfer(user2, new BN(10).pow(new BN(27)).mul(new BN(3)), { from: userAdmin });
        const user1StakeReceipt = await this.oreLockerVault.depositLocker(0, new BN(10).pow(new BN(27)), { from: user1 });
        expectEvent(user1StakeReceipt, "OreLockerVaultDeposited", { user: user1, period: new BN(60*60*24*7), amount: new BN(10).pow(new BN(27)) });
        expect(await this.oreLockerVault.totalAmount()).to.be.bignumber.equal(new BN(10).pow(new BN(27)));
        expect(await this.oreLockerVault.balance({ from: user1 })).to.be.bignumber.equal(new BN(10).pow(new BN(27)));
        expect(await this.oreLockerVault.unlockedBalance({ from: user1 })).to.be.bignumber.equal(new BN(0));

        // console.log("test ore amount: " + await this.oreLockerVault.rewardOreAmount(new BN(10).pow(new BN(27)), new BN(100)));
        expect(await this.tokauTreasures.balanceOf(user1, oreTokenId)).to.be.bignumber.equal(new BN(1));
        
        const user2StakeReceipt = await this.oreLockerVault.depositLocker(1, new BN(10).pow(new BN(27)).mul(new BN(3)), { from: user2 });
        expectEvent(user2StakeReceipt, "OreLockerVaultDeposited", { user: user2, period: new BN(60*60*24*14), amount: new BN(10).pow(new BN(27)).mul(new BN(3)) });
        expect(await this.oreLockerVault.totalAmount()).to.be.bignumber.equal(new BN(10).pow(new BN(27)).mul(new BN(4)));
        expect(await this.oreLockerVault.balance({ from: user2 })).to.be.bignumber.equal(new BN(10).pow(new BN(27)).mul(new BN(3)));
        expect(await this.oreLockerVault.unlockedBalance({ from: user2 })).to.be.bignumber.equal(new BN(0));

        // console.log("test ore amount: " + await this.oreLockerVault.rewardOreAmount(new BN(10).pow(new BN(27)).mul(new BN(3)), new BN(125)));
        expect(await this.tokauTreasures.balanceOf(user2, oreTokenId)).to.be.bignumber.equal(new BN(3));
    });

    it("change booster parameters", async() => {
        await this.oreLockerVault.setEmissionRate(new BN(2));
        await this.oreLockerVault.setLockerPeroids([new BN(60*60*24*28), new BN(60*60*24*42)], [new BN(150), new BN(200)]);
        
    });
});