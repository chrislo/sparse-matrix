require File.expand_path( File.join( File.dirname( __FILE__ ), 'test_helper' ) )

# add somce accessor so we can check under the hood
class SparseVector
  def elems; @elements end
end

class TestSparseVector < Test::Unit::TestCase

  # CREATION

  def test_creation_array
    sv = SparseVector[1,0,2,3,0,0]
    assert sv.size == 6
    assert sv.nnz == 3
    assert sv.elems == { 0 => 1, 2 => 2, 3 => 3 }
    assert sv.elems.default == 0
  end

  def test_creation_elements
    sv1 = SparseVector.elements([0,3,6,2,0,0])
    assert sv1.size == 6
    assert sv1.nnz == 3
    assert sv1.elems == { 1 => 3, 2 => 6, 3 => 2 }
    assert sv1.elems.default == 0

    sv2 = SparseVector.elements({ 2 => 3, 5 => 1, 6 => 7 })
    assert sv2.size == 7
    assert sv2.nnz == 3
    assert sv2.elems == { 2 => 3, 5 => 1, 6 => 7 }
    assert sv2.elems.default == 0

    sv3 = SparseVector.elements(Vector[0,2,4,0,0,1,0,0])
    assert sv3.size == 8
    assert sv3.nnz == 3
    assert sv3.elems == { 1 => 2, 2 => 4, 5 => 1 }
    assert sv3.elems.default == 0
  end

  # ACCESS

  def test_access
    sv = SparseVector.elements([0,3,6,2,0,0])
    assert sv[0] == 0
    assert sv[1] == 3
    assert sv[2] == 6
    assert sv[3] == 2
    assert sv[10].nil?
    assert sv.element(1) == sv[1]
    assert sv.component(1) == sv[1]
  end

  # ENUMERATION

  def test_each
    sv = SparseVector.elements([0,3,6,2,0,0])
    ret_array = []
    sv.each do |k|
      ret_array << k
    end

    assert ret_array == [0,3,6,2,0,0]
  end

  def test_each_nz
    sv = SparseVector.elements([0,3,6,2,0,0])
    ret_array = []
    sv.each_nz do |k|
      ret_array << k
    end

    assert ret_array == [3,6,2]
  end

  def test_each2
    sv1 = SparseVector.elements([0,3,0,2,0,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0])
    ret_array = []
    sv1.each2(sv2) do |k,l|
      ret_array << [k,l]
    end

    assert ret_array == [[0,1],[3,0],[0,0],[2,2],[0,6],[0,0]]
  end

  def test_each2_nz
    sv1 = SparseVector.elements([0,3,0,2,0,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0])
    ret_array = []
    sv1.each2_nz(sv2) do |k,l|
      ret_array << [k,l]
    end

    assert ret_array == [[0,1],[3,0],[2,2],[0,6]]
  end

  def test_collect2
    sv1 = SparseVector.elements([0,3,0,2,0,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0])
    ret_array = sv1.collect2(sv2) do |k,l|
      k != 0 || l != 0
    end

    assert ret_array == [true,true,false,true,true,false]
  end

  def test_collect2_nz
    sv1 = SparseVector.elements([0,3,0,2,0,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0])
    ret_array = sv1.collect2_nz(sv2) do |k,l|
      k != 0 || l != 0
    end

    assert ret_array == [true,true,nil,true,true,nil]
  end

  def test_collect
    sv = SparseVector.elements([0,3,0,2,0,0])
    ret_sv = sv.collect { |v| v * 2 }

    assert ret_sv == SparseVector.elements([0,6,0,4,0,0])
  end

  def test_map2
    sv1 = SparseVector.elements([0,3,0,2,0,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0])
    ret_sv = sv1.map2(sv2) do |k,l|
      (k * 2) + l + 3
    end

    assert ret_sv == SparseVector[4,9,3,9,9,3]
  end

  def test_map2_nz
    sv1 = SparseVector.elements([0,3,0,2,0,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0])
    ret_sv = sv1.map2_nz(sv2) do |k,l|
      (k * 2) + l + 3
    end

    assert ret_sv == SparseVector[4,9,0,9,9,0]
  end

  # ARITHMETIC

  def test_addition_sparse_vector
    sv1 = SparseVector.elements([0,3,0,2,0,0,3,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0,5,0])

    assert (sv1 + sv2) == SparseVector[1,3,0,4,6,0,8,0]
  end

  def test_addition_vector
    sv = SparseVector.elements([0,3,0,2,0,0,3,0])
    v  = Vector.elements([1,0,0,2,6,0,5,0])

    assert (sv + v) == SparseVector[1,3,0,4,6,0,8,0]
  end

  def test_addition_sparse_matrix
  end

  def test_addition_matrix
  end

  def test_subtraction_sparse_vector
    sv1 = SparseVector.elements([0,3,0,2,0,0,3,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0,5,0])

    assert (sv1 - sv2) == SparseVector[-1,3,0,0,-6,0,-2,0]
  end

  def test_subtraction_vector
    sv = SparseVector.elements([0,3,0,2,0,0,3,0])
    v  = Vector.elements([1,0,0,2,6,0,5,0])

    assert (sv - v) == SparseVector[-1,3,0,0,-6,0,-2,0]
  end

  def test_subtraction_sparse_matrix
  end

  def test_subtraction_matrix
  end

  def test_multiplication_numeric
    sv = SparseVector.elements([0,3,0,2,0,0,3,0])

    assert (sv * 3) == SparseVector[0,9,0,6,0,0,9,0]
  end

  def test_multiplication_sparse_matrix
  end

  def test_multiplication_matrix
  end

  def test_division_numeric
    sv = SparseVector.elements([0,8,0,2,0,0,6,0])

    assert (sv / 2) == SparseVector[0,4,0,1,0,0,3,0]
  end

  def test_division_sparse_matrix
  end

  def test_division_matrix
  end

  # VECTOR FUNCTIONS

  def test_inner_product
    sv1 = SparseVector.elements([0,3,0,2,0,0,3,0])
    sv2 = SparseVector.elements([1,0,0,2,6,0,5,0])

    assert sv1.inner_product(sv2) == 19
  end

  def test_r
    sv = SparseVector.elements([0,3,0,2,0,0,3,0])

    assert sv.r == Math.sqrt(22)
  end

  # CONVERTING

  def test_covector
  end

  def test_to_a
    sv = SparseVector.elements([0,3,0,2,0,0,3,0])

    assert sv.to_a == [0,3,0,2,0,0,3,0]
  end

  def test_to_v
    sv = SparseVector.elements([0,3,0,2,0,0,3,0])

    assert sv.to_v == Vector[0,3,0,2,0,0,3,0]
  end

  def test_elements_to_f
  end

  def test_elements_to_i
  end

  def test_elements_to_r
  end

end