#[contract]
mod ERC20 {
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::ContractAddressZeroable;
    use zeroable::Zeroable;

    use protostar_contract_01::error;

    struct Storage {
        name_: felt252,
        symbol_: felt252,
        totalSupply_: u256,
        balances_: LegacyMap::<ContractAddress, u256>,
        allowances_: LegacyMap::<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, amount: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, amount: u256) {}

    #[constructor]
    fn constructor(_name: felt252, _symbol: felt252) {
        name_::write(_name);
        symbol_::write(_symbol);
    }

    #[view]
    fn name() -> felt252 {
        name_::read()
    }

    #[view]
    fn symbol() -> felt252 {
        symbol_::read()
    }

    #[view]
    fn decimal() -> u8 {
        18_u8
    }

    #[view]
    fn totalSupply() -> u256 {
        totalSupply_::read()
    }

    #[view]
    fn balanceOf(_user: ContractAddress) -> u256 {
        balances_::read(_user)
    }

    #[view]
    fn allowance(_owner: ContractAddress, _spender: ContractAddress) -> u256 {
        allowances_::read((_owner, _spender))
    }

    #[external]
    fn transfer(_to: ContractAddress, _amount: u256) -> bool {
        let _msgSender = get_caller_address();
        _transfer(_msgSender, _to, _amount);
        true
    }

    #[external]
    fn transferFrom(_from: ContractAddress, _to: ContractAddress, _amount: u256) -> bool {
        let _spender = get_caller_address();
        _spendAllowance(_from, _spender, _amount);
        _transfer(_from, _to, _amount);
        true
    }

    #[external]
    fn mint(_receiver: ContractAddress, _amount: u256) {
        _mint(_receiver, _amount);
    }

    #[external]
    fn approve(_spender: ContractAddress, _amount: u256) -> bool {
        let _msgSender = get_caller_address();
        _approve(_msgSender, _spender, _amount);
        true
    }

    #[external]
    fn increaseAllowance(_spender: ContractAddress, _addedAmount: u256) -> bool {
        let _msgSender = get_caller_address();
        _approve(_msgSender, _spender, allowances_::read((_msgSender, _spender)) + _addedAmount);
        true
    }

    #[external]
    fn decreaseAllowance(_spender: ContractAddress, _subedAmount: u256) -> bool {
        let _msgSender = get_caller_address();
        let currentAllowance = allowances_::read((_msgSender, _spender));
        assert(currentAllowance >= _subedAmount, error::INSUFFICIENT_ALLOWANCE);
        _approve(_msgSender, _spender, currentAllowance - _subedAmount);
        true
    }

    // ========== internal functions ==========

    fn _transfer(_from: ContractAddress, _to: ContractAddress, _amount: u256) {
        assert(_from.is_non_zero(), error::ADDRESS_NOT_ZERO_ERROR);
        assert(_to.is_non_zero(), error::ADDRESS_NOT_ZERO_ERROR);

        let fromBalance = balances_::read(_from);
        assert(fromBalance >= _amount, error::INSUFFICIENT_FUNDS);
        balances_::write(_from, fromBalance - _amount);

        let toBalance = balances_::read(_to);
        balances_::write(_to, toBalance + _amount);

        Transfer(_from, _to, _amount);
    }

    fn _mint(_account: ContractAddress, _amount: u256){
        assert(_account.is_non_zero(), error::ADDRESS_NOT_ZERO_ERROR);

        totalSupply_::write(totalSupply_::read() + _amount);
        balances_::write(_account, balances_::read(_account) + _amount);

        // TODO: 如何调用 impl ？ 直接导入impl就可以了 这里需要同时导入两个：ContractAddressZeroable & Zeroable
        Transfer(Zeroable::zero() , _account, _amount);
    }

    fn _approve(_owner: ContractAddress, _spender: ContractAddress, _amount: u256) {
        assert(_owner.is_non_zero(), error::ADDRESS_NOT_ZERO_ERROR);
        assert(_spender.is_non_zero(), error::ADDRESS_NOT_ZERO_ERROR);

        allowances_::write((_owner, _spender), _amount);
        Approval(_owner, _spender, _amount);
    }

    fn _spendAllowance(_owner: ContractAddress, _spender: ContractAddress, _amount: u256) {
        let currentAllowance = allowances_::read((_owner, _spender));
        assert(currentAllowance >= _amount, error::INSUFFICIENT_ALLOWANCE);
        _approve(_owner, _spender, currentAllowance - _amount);
    }
}
