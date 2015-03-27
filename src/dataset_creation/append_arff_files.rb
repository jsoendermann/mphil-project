#! /usr/bin/env ruby

DATASETS_DIR = '/Users/jan/mphil_project_datasets/'

Dir.foreach(DATASETS_DIR) do |item|
    if item[0] == '.'
        next
    end

        
    train_file = DATASETS_DIR + item + '/train.arff'
    test_file = DATASETS_DIR + item + '/test.arff'
    output_file = DATASETS_DIR + item + "/#{item}.arff"

    puts "Processing #{item}..."

    system "export CLASSPATH=/Users/jan/weka-3-6-12/weka.jar && java weka.core.Instances append #{train_file} #{test_file} > #{output_file}"
end
