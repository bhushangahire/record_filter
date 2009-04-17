require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'RecordFilter restrictions' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  it 'should filter for equality' do
    Post.filter do
      with :permalink, 'blog-post'
    end.inspect
    Post.last_find.should == { :conditions => [%q{"posts".permalink = ?}, 'blog-post'] }
  end

  it 'should filter for equality with multiple conditions' do
    Post.filter do
      with :permalink, 'blog-post'
      with :blog_id, 3
    end.inspect
    Post.last_find.should == { :conditions => [%q{("posts".permalink = ?) AND ("posts".blog_id = ?)}, 'blog-post', 3] }
  end

  it 'should filter by comparison operators' do
    [[:greater_than, :gt, '>'], [:less_than, :lt, '<'], 
     [:less_than_or_equal_to, :lte, '<='], [:greater_than_or_equal_to, :gte, '>=']].each do |set|
       Post.filter do
         with(:created_at).send(set[0], Time.parse('2009-01-03 23:02:00'))
       end.inspect
       Post.last_find.should == { :conditions => ["\"posts\".created_at #{set[2]} ?", Time.parse('2009-01-03 23:02:00')] }

       Post.filter do
         with(:created_at).send(set[1], Time.parse('2009-01-03 23:02:00'))
       end.inspect
       Post.last_find.should == { :conditions => ["\"posts\".created_at #{set[2]} ?", Time.parse('2009-01-03 23:02:00')] }
     end
  end

  it 'should filter for in' do
    Post.filter do
      with(:blog_id).in [1, 3, 5]
    end.inspect
    Post.last_find.should == { :conditions => [%q{"posts".blog_id IN (?)}, [1, 3, 5]] }
  end

  it 'should filter for between' do
    time1 = Time.parse('2008-01-03 23:23:00')
    time2 = Time.parse('2008-01-03 23:36:00')
    Post.filter do
      with(:created_at).between time1..time2
    end.inspect
    Post.last_find.should == { :conditions => [%q{"posts".created_at BETWEEN ? AND ?}, time1, time2] }
  end

  it 'should filter by disjunction' do
    Post.filter do
      any_of do
        with(:blog_id).equal_to 1
        with(:permalink).equal_to 'my-post'
      end
    end.inspect
    Post.last_find.should == { :conditions => [%q{("posts".blog_id = ?) OR ("posts".permalink = ?)}, 1, 'my-post'] }
  end

  it 'should filter by disjunction composed of conjunction' do
    Post.filter do
      any_of do
        all_of do
          with(:blog_id).equal_to 1
          with(:permalink).equal_to 'my-post'
        end
        with(:permalink).equal_to 'another-post'
      end
    end.inspect

    Post.last_find.should == { :conditions => [%q{(("posts".blog_id = ?) AND ("posts".permalink = ?)) OR ("posts".permalink = ?)},
                                               1, 'my-post', 'another-post'] }
  end

  it 'should filter for nil' do
    [:is_null, :null, :nil].each do |method|
      Post.filter do
        with(:permalink).send(method)
      end.inspect
      Post.last_find.should == { :conditions => [%q("posts".permalink IS NULL)] }
    end
  end

  it 'should support like' do
    Post.filter do
      with(:permalink).like('%piglets%')
    end.inspect
    Post.last_find.should == { :conditions => [%q("posts".permalink LIKE ?), '%piglets%'] }
  end

  it 'should support NOT LIKE' do
    Post.filter do
      without(:permalink).like('%ostriches%')
    end.inspect
    Post.last_find.should == { :conditions => [%q("posts".permalink NOT LIKE ?), '%ostriches%'] }
  end
end
