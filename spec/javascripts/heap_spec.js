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

  function addSampleBoxes(el, n) {
    for(var i = 0; i < n; i++) {
      var b = box.clone();
      b.data('index', i);
      b.appendTo(el);
    }

    return $('.box', el);
  }

  describe('el.heapify(boxes)', function(){

    var boxes, firstBox;

    beforeEach(function(){
      boxes = addSampleBoxes(el, 5)
      el.heapify('.box');
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

  describe('el.heapify(boxes, { sort: true/false })', function(){

    var boxes, firstBox;

    beforeEach(function(){
      boxes = addSampleBoxes(el, 3);
    });

    it("places the largest boxes first", function(){
      // reverse size order
      boxes.eq(0).css({ width: '90px', height: '90px' });
      boxes.eq(2).css({ width: '110px', height: '110px' });

      el.heapify('.box', { sort: true });

      // last should be in the center
      var position = boxes.eq(2).position();
      expect( Math.round(position.top) ).toEqual(90);
      expect( Math.round(position.left) ).toEqual(90);
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
