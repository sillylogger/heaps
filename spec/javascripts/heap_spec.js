describe('Heap', function(){

  var el, box;

  beforeEach(function(){
    var body = $('#jasmine_content').empty();

    el = $('<div id="test" class="boxes"> </div>');
    el.appendTo(body);

    box = $('<div class="box"> </div>');
  });

  it('has a canvas size of 300px', function(){
    expect( el.width() ).toEqual( 300 );
    expect( el.height() ).toEqual( 300 );
  });

  it('has boxes of size 100px', function(){
    el.append(box);
    expect( box.width() ).toEqual( 100 );
    expect( box.height() ).toEqual( 100 );
  });

  describe('el.heapify(boxes)', function(){

    var boxes, firstBox;

    beforeEach(function(){
      for(var i = 0; i < 5; i++) {
        var b = box.clone();
        b.data('index', i);
        b.appendTo(el);
      }

      expect( $('.box', el).size() ).toEqual(5);

      el.heapify('.box');

      boxes = $('.box', el);
      expect( boxes.size() ).toEqual(5);
      firstBox = boxes.first();
    });

    it('puts the first box in the center', function(){
      var position = firstBox.position();
      /* this is a 100x100 box on a 300x300 canvas == offset of 100x100 */
      expect( Math.round(position.top) ).toEqual(100);
      expect( Math.round(position.left) ).toEqual(100);
    });

    it('builds a simple cross for 5 boxes', function(){
      var validPositions =  [ [0, 100],
                              [100, 0],
                              [200, 100],
                              [100, 200] ];

      boxes.not(firstBox).each(function(i, el){
        var position = $(el).position();
        position = [ Math.round(position.left) , Math.round(position.top) ];
        expect(validPositions).toContain( position );
      });
    });
  });

  // helper functions
  describe('helper functions', function(){
    var heap;

    beforeEach(function(){
      el.heapify();
      heap = el.data('heap');
    });

    describe('findBestPosition', function(){
      it('returns a would-be centered box', function(){
        expect( heap.findBestPosition(20,20) ).toEqual([140, 140]);
        expect( heap.findBestPosition(300,300) ).toEqual([0, 0]);
        expect( heap.findBestPosition(301,301) ).toBeUndefined();
      });
    });
  });

});
