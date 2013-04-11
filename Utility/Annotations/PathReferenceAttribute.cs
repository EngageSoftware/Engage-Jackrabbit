// <copyright file="PathReferenceAttribute.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;
    using System.Diagnostics.CodeAnalysis;

    /// <summary>Indicates that a parameter is a path to a file or a folder within a web project.
    /// Path can be relative or absolute, starting from web root (~).</summary>
    [SuppressMessage("Microsoft.Performance", "CA1813:AvoidUnsealedAttributes", Justification = "Jetbrains code")]
    [AttributeUsage(AttributeTargets.Parameter)]
    public class PathReferenceAttribute : Attribute
    {
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public PathReferenceAttribute()
        {
        }

        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public PathReferenceAttribute([PathReference] string basePath)
        {
            this.BasePath = basePath;
        }

        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public string BasePath { get; private set; }
    }
}