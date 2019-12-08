img = parse.(Int,split(strip(read("8.input",String)),""))
imgs = reshape(img,(25,6,:))
layer_min_zero = argmin(count.(==(0),eachslice(imgs,dims=3)))
count(==(1),imgs[:,:,layer_min_zero]) * count(==(2),imgs[:,:,layer_min_zero])

# # Part 2
# The digits indicate the color of the corresponding pixel: 0 is black, 1 is
# white, and 2 is transparent.

function reduce_img(img)
    new_img = zeros(Int,25,6)
    for r in 1:25, c in 1:6
        idx = findfirst(!(==(2)),img[r,c,:])
        new_img[r,c] = img[r,c,idx]
    end
    new_img
end

using Images

function render(img)
    for c in 1:size(img,2)
        for r in 1:size(img,1)
            img[r,c] == 0 && print("█")
            img[r,c] == 1 && print(" ")
        end
        println()
    end
end

render(reduce_img(imgs))