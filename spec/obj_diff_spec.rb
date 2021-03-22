require_relative '../obj_diff'

describe ObjDiff do
  describe 'flame test' do
    it 'works' do
      result = ObjDiff[1, 1]
      expect(result).to(eq(nil))
    end

    it 'works with diff' do
      a = {
        foo: 123,
        bar: [1,2,3],
      }
      
      b = {
        foo: 123,
        bar: [1,2,3,4],
      }
      
      result = ObjDiff[a, b]
      expect(result.property).to(eq('_[:bar]'))
    end

    it 'does not get caught by circular refs' do
      x = { foo: 123 }
      x[:bar] = x

      lhs = {
        x: x,
        y: 'no',
      }
      rhs = {
        x: x,
        y: 123,
      }
      result = ObjDiff[lhs, rhs]
      expect(result.property).to(eq('_[:y]'))
    end

    it 'cares about ordered enums' do
      result = ObjDiff[[1,2], [2,1]]
      expect(result.property).to(eq('_[0]'))

      result = ObjDiff[[1,2], [1,2]]
      expect(result).to(eq(nil))
    end

    it 'cares about non ordered enums' do
      require 'set'

      result = ObjDiff[Set.new([1,2]), Set.new([2,1])]
      expect(result).to(eq(nil))
    end
  end
end
