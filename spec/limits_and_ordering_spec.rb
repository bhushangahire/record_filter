require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'filter qualifiers' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'limits' do
    describe 'simple limit setting' do
      before do
        Post.filter do
          with :published, true
          limit 10
        end.inspect
      end

      it 'should add the limit to the parameters' do
        Post.last_find[:limit].should == 10
      end
    end

    describe 'with multiple calls to limit' do
      before do
        Post.filter do
          limit 5
          with :published, true
          limit 6
        end.inspect
      end

      it 'should add the limit to the parameters' do
        Post.last_find[:limit].should == 6 
      end
    end

    describe 'limiting named scopes' do
      before do
        Post.named_filter(:published) do
          with :published, true
          limit 6
        end
      end

      it 'should limit the query' do
        Post.published.inspect
        Post.last_find[:limit].should == 6
      end
    end

    describe 'with a limit that includes an offset' do
      before do
        Post.filter do
          with :published, true
          limit(20, 10)
        end.inspect
      end

      it 'should provide an offset and a limit' do
        Post.last_find[:limit].should == 10
        Post.last_find[:offset].should == 20
      end
    end
  end

  describe 'ordering' do
    describe 'with a simple order supplied' do
      before do
        Post.filter do
          with :published, true
          order(:permalink)
        end.inspect
      end

      it 'should add the order to the query' do
        Post.last_find[:order].should == 'posts.permalink ASC'
      end
    end

    describe 'with an explicit direction' do
      before do
        Post.filter do
          with :published, true
          order(:permalink, :desc)
        end.inspect
      end

      it 'should add the order and direction to the query' do
        Post.last_find[:order].should == 'posts.permalink DESC'
      end
    end

    describe 'with multiple order clauses' do
      before do
        Post.filter do
          with :published, true
          order(:permalink, :desc)
          order(:id)
        end.inspect
      end

      it 'should add both orders and directions to the query' do
        Post.last_find[:order].should == 'posts.permalink DESC, posts.id ASC'
      end
    end

    describe 'with joins' do
      before do
        Post.filter do
          having(:photo) do
            with :format, 'jpg'
          end
          order({ :photo => :path }, :desc)
          order :permalink
        end.inspect
      end

      it 'should add the limit to the parameters' do
        Post.last_find[:order].should == 'photos.path DESC, posts.permalink ASC' 
      end
    end

    describe 'limiting methods within joins and conjunctions' do
      it 'should not allow calls to limit within joins' do
        lambda {
          Post.filter do
            having(:photo) do
              limit 2
            end
          end
        }.should raise_error(NoMethodError)
      end

      it 'should not allow calls to order within joins' do
        lambda {
          Post.filter do
            having(:photo) do
              order :id
            end
          end
        }.should raise_error(NoMethodError)
      end

      it 'should not allow calls to limit within conjunctions' do
        lambda {
          Post.filter do
            all_of do
              limit 2
            end
          end
        }.should raise_error(NoMethodError)
      end

      it 'should not allow calls to order within joins' do
        lambda {
          Post.filter do
            all_of do
              order :id
            end
          end
        }.should raise_error(NoMethodError)
      end
    end
  end
end