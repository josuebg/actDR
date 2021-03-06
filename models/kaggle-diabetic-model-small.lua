-- Author: Tristan Swedish - 2016
-- Based on o_O solution to Kaggle Diabetic Retinopathy 2015 Challenge

require 'torch'
require 'nn'

local features = nn.Sequential()

-- remember to remove this code! (util.multi)
--multi = require('util.multi')

--features:add(nn.SpatialBatchNormalization(3)) -- normalize inputs...

-- nn.SpatialConvolution(nI, nO, kW, kH, [dW], [dH], [padW], [padH])
-- nn.SpatialMaxPooling(kW, kH [, dW, dH, padW, padH])
-- spatial_size = floor((input  + 2*padW - kW) / dW + 1)
-- spatial_size = input: 256 -- small
features:add(nn.SpatialConvolution(3,32,4,4,2,2))
-- spatial_size = 127 -small
features:add(nn.SpatialBatchNormalization(32))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialConvolution(32,32,4,4,1,1,2,2))
-- spatial_size = 128 -small
features:add(nn.SpatialBatchNormalization(32))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialMaxPooling(3,3,2,2))
-- spatial_size = 63 -small

features:add(nn.SpatialConvolution(32,64,4,4,2,2))
-- spatial_size = 30 -small
features:add(nn.SpatialBatchNormalization(64))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialConvolution(64,64,4,4,1,1,2,2))
-- spatial_size = 31 -small
features:add(nn.SpatialBatchNormalization(64))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialConvolution(64,64,4,4))
-- spatial_size = 32 -small
features:add(nn.SpatialBatchNormalization(64))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialMaxPooling(3,3,2,2))
-- spatial_size = 15 -small

features:add(nn.SpatialConvolution(64,128,4,4,1,1))
-- spatial_size = 12 -small
features:add(nn.SpatialBatchNormalization(128))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialConvolution(128,128,4,4,1,1,2,2))
-- spatial_size = 13 -small
features:add(nn.SpatialBatchNormalization(128))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialConvolution(128,128,4,4,1,1,1,1))
-- spatial_size = 12 -small
features:add(nn.SpatialBatchNormalization(128))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialMaxPooling(3,3,2,2))
-- spatial_size = 5 -small

features:add(nn.SpatialConvolution(128,256,4,4,1,1,2,2))
-- spatial_size = 6 -small
features:add(nn.SpatialBatchNormalization(256))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialConvolution(256,256,4,4,1,1,1,1))
-- spatial_size = 5 -small
features:add(nn.SpatialBatchNormalization(256))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialConvolution(256,256,4,4,1,1,2,2))
-- spatial_size = 6 -small
features:add(nn.SpatialBatchNormalization(256))
features:add(nn.LeakyReLU(0.03,true))
features:add(nn.SpatialMaxPooling(3,3,2,2))
-- spatial_size = 2 -small

--features:add(nn.SpatialConvolution(256,512,4,4,1,1,1,1))
-- spatial_size = 2 -small
--features:add(nn.SpatialBatchNormalization(512))
--features:add(nn.LeakyReLU(0.3,true))
--features:add(nn.SpatialLPPooling(512,2,3,3,2,2))
-- spatial_size = 2
features:add(nn.View(256*4):setNumInputDims(3))

features:cuda()

local classifier = nn.Sequential()
classifier:add(nn.Dropout(0.5))
classifier:add(nn.Linear(256*4,1024))
classifier:add(nn.BatchNormalization(1024))
classifier:add(nn.LeakyReLU(0.03,true))
classifier:add(nn.View(1024,1):setNumInputDims(1))
classifier:add(nn.TemporalMaxPooling(2,2))
classifier:add(nn.View(512):setNumInputDims(2))
classifier:add(nn.Dropout(0.5))
classifier:add(nn.Linear(512,1024))
classifier:add(nn.BatchNormalization(1024))
classifier:add(nn.LeakyReLU(0.03,true))
classifier:add(nn.View(1024,1):setNumInputDims(1))
classifier:add(nn.TemporalMaxPooling(2,2))
classifier:add(nn.View(512):setNumInputDims(2))
--classifier:add(nn.Linear(512,5))
classifier:add(nn.Linear(512,1))
--classifier:add(nn.LogSoftMax())
classifier:cuda()

local model = nn.Sequential()

model:add(features)
model:add(classifier)

return model
