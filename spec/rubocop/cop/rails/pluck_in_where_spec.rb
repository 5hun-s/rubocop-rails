# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PluckInWhere, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  shared_examples 'receiver is a constant for `pluck`' do
    it 'registers an offense and corrects when using `pluck` in `where` for constant' do
      expect_offense(<<~RUBY)
        Post.where(user_id: User.active.pluck(:id))
                                        ^^^^^ Use `select` instead of `pluck` within `where` query method.
      RUBY

      expect_correction(<<~RUBY)
        Post.where(user_id: User.active.select(:id))
      RUBY
    end

    it 'registers an offense and corrects when using `pluck` in `rewhere` for constant' do
      expect_offense(<<~RUBY)
        Post.rewhere('user_id IN (?)', User.active.pluck(:id))
                                                   ^^^^^ Use `select` instead of `pluck` within `where` query method.
      RUBY

      expect_correction(<<~RUBY)
        Post.rewhere('user_id IN (?)', User.active.select(:id))
      RUBY
    end

    it 'does not register an offense when using `select` in `where`' do
      expect_no_offenses(<<~RUBY)
        Post.where(user_id: User.active.select(:id))
      RUBY
    end

    it 'does not register an offense when using `pluck` chained with other method calls in `where`' do
      expect_no_offenses(<<~RUBY)
        Post.where(user_id: User.pluck(:id).map(&:to_i))
      RUBY
    end

    it 'does not register an offense when using `select` in query methods other than `where`' do
      expect_no_offenses(<<~RUBY)
        Post.order(columns.pluck(:name))
      RUBY
    end
  end

  context 'EnforcedStyle: conservative' do
    let(:enforced_style) { 'conservative' }

    it_behaves_like 'receiver is a constant for `pluck`'

    context 'receiver is a variable for `pluck`' do
      it 'does not register an offense when using `pluck` in `where`' do
        expect_no_offenses(<<~RUBY)
          Post.where(user_id: users.active.pluck(:id))
        RUBY
      end
    end
  end

  context 'EnforcedStyle: aggressive' do
    let(:enforced_style) { 'aggressive' }

    it_behaves_like 'receiver is a constant for `pluck`'

    context 'receiver is a variable for `pluck`' do
      it 'registers and corrects an offense when using `pluck` in `where`' do
        expect_offense(<<~RUBY)
          Post.where(user_id: users.active.pluck(:id))
                                           ^^^^^ Use `select` instead of `pluck` within `where` query method.
        RUBY

        expect_correction(<<~RUBY)
          Post.where(user_id: users.active.select(:id))
        RUBY
      end
    end
  end
end
